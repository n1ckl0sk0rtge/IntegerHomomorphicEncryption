//
//  HECryptoModule.swift
//  IntegerHomomorphicEncryption
//
//  Created by Nicklas Körtge on 09.04.21.
//

import Foundation


class HECryproModule {
    
    let securityParameter : Int
    let degree : Int
    let distribution : Distribution
    let context : Context
    
    struct Context {
        let decomposeBase : Double
        let messageSpace : Double
        let parameter_q : Int64
        let ringPolynomial : Polynomial
        
        func equals(context: Context) -> Bool {
            return (self.decomposeBase == context.decomposeBase &&
                    self.messageSpace == context.messageSpace &&
                    self.parameter_q == context.parameter_q &&
                    self.ringPolynomial == context.ringPolynomial)
        }
    }
    
    struct PublicKey {
        let context: Context
        let pk0 : Polynomial
        let pk1 : Polynomial
        let evaluationKey : EvaluationKey
    }
    
    struct EvaluationKey {
        let rlks0 : [Polynomial]
        let rlks1 : [Polynomial]
    }
    
    struct PrivateKey {
        let sk : Polynomial
    }
    
    init(securityParameter : Int, degree : Int, decomposeBase : Int, messageSpace : Int, parameter_q : Int, ringPolynomial : Polynomial, distribution: Distribution) {
        self.securityParameter = Int(securityParameter)
        self.degree = Int(degree)
        self.context = Context(decomposeBase: Double(decomposeBase), messageSpace: Double(messageSpace), parameter_q: Int64(parameter_q), ringPolynomial: ringPolynomial)
        self.distribution = distribution
    }
    
    init() {
        self.securityParameter = 4
        self.degree = Int(pow(2.0, Double(securityParameter)))
        self.context = Context(decomposeBase: 2,
                               messageSpace: pow(2.0, 10.0),
                               parameter_q: Int64(pow(2.0, 20.0) * Double(Int(pow(2.0, 10.0)))),
                               ringPolynomial: Polynomial(coefficients: Array<Int64>([1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]))) //x^16+1
        self.distribution = NormalDistribution(mean: 0.0, deviation: 2.0)
    }
    
    
    /// This function creates the public and private key for the encryption
    /// - Returns: tuple of public key and private key
    func createKeypair() -> (PublicKey, PrivateKey) {
        
        // private key
        let s = createPolynomial(of: self.degree, in: 0...1)
        
        // public key
        let a = createPolynomial(of: self.degree, in: 0...self.context.parameter_q-1) //%% self.parameter_q
        let e = createPolynomial(of: self.degree, with: distribution) %% self.context.parameter_q
        let pk0 = HECryproModule.stripPolynomial(polynomial: ((a * s) * -1.0) + e, moduloPolynomial: self.context.ringPolynomial, moduloInt: self.context.parameter_q)
        let pk1 = a
        
        // evaluation key
        let l = Int(floor(log_b(Double(self.context.parameter_q), Double(self.context.decomposeBase))))
        
        var rlks0 = [Polynomial]()
        var rlks1 = [Polynomial]()
        
        for i in 0..<(l + 1) {
            let a_i = createPolynomial(of: self.degree, in: 0...self.context.parameter_q-1)
            let e_i = createPolynomial(of: self.degree, with: distribution) %% self.context.parameter_q
            
            let rlk0_t = (((a_i * s) * -1.0) + e_i) + ((powP(lhs: s, rhs: 2)) * pow(self.context.decomposeBase, Double(i)))
            let rlk0 = HECryproModule.stripPolynomial(polynomial: rlk0_t, moduloPolynomial: self.context.ringPolynomial, moduloInt: self.context.parameter_q)
            rlks0.append(rlk0)
            
            let rlk1 = a_i
            rlks1.append(rlk1)
        }
        
        let evalKey = EvaluationKey(rlks0: rlks0, rlks1: rlks1)
        
        return (PublicKey(context: context, pk0: pk0, pk1: pk1, evaluationKey: evalKey), PrivateKey(sk: s))
    }
    
    func encrypt(message: Int, with publickey: PublicKey) -> EncryptedInteger {
        let u = createPolynomial(of: self.degree, with: distribution) %% self.context.parameter_q
        
        let e1 = createPolynomial(of: self.degree, with: distribution) %% self.context.parameter_q
        let e2 = createPolynomial(of: self.degree, with: distribution) %% self.context.parameter_q
        
        let delta = floor(Double(self.context.parameter_q) / self.context.messageSpace)
        
        let c0 = HECryproModule.stripPolynomial(polynomial: (publickey.pk0 * u) + e1 + (delta * Double(message)), moduloPolynomial: self.context.ringPolynomial, moduloInt: self.context.parameter_q)
        let c1 = HECryproModule.stripPolynomial(polynomial: (publickey.pk1 * u) + e2, moduloPolynomial: self.context.ringPolynomial, moduloInt: self.context.parameter_q)
        
        return EncryptedInteger(c0: c0, c1: c1, context: self.context)
    }
    
    func encrypt(message: String, with publickey: PublicKey) -> EncryptedString {
        
        let lzw_compressed = LZW.shared.compress(message)
        
        var encryptedCodes = [EncryptedInteger]()
                
        for code in lzw_compressed {
            encryptedCodes.append(encrypt(message: code, with: publickey))
        }
        return EncryptedString(code: encryptedCodes)
    }
    
    func decrypt(cipher: EncryptedInteger, with privatekey: PrivateKey) -> Int {
        let q2 = self.context.messageSpace / Double(self.context.parameter_q)
        let v = HECryproModule.stripPolynomial(polynomial: cipher.c0 + cipher.c1 * privatekey.sk, moduloPolynomial: self.context.ringPolynomial, moduloInt: self.context.parameter_q)
        var res = (v * q2).roundP()
        res = res %% Int64(self.context.messageSpace)
        return Int(res.coefficients[0])
    }
    
    func decrypt(cipher: EncryptedString, with privatekey: PrivateKey) -> String? {
        
        var lzw_encoded = [Int]()
        
        for encryptedCode in cipher.code {
            lzw_encoded.append(decrypt(cipher: encryptedCode, with: privatekey))
        }
        
        return LZW.shared.decompress(lzw_encoded)
    }
    
    static func baseDecomposition(polynomial: Polynomial, base: Int64, moduloInt: Int64) -> [Polynomial] {
        let l = Int(floor(log_b(Double(moduloInt), Double(base))))
        
        var result = [Polynomial]()
        
        for i in 0..<(l + 1) {
            let rebase = (polynomial / (pow(Double(base), Double(i)))).floorP()
            result.append(rebase %% base)
        }
        
        return result
    }
    
    static func stripPolynomial(polynomial: Polynomial, moduloPolynomial: Polynomial, moduloInt: Int64) -> Polynomial {
        let poly_div = polynomial / moduloPolynomial
        let poly_res = poly_div.0.floorP()
        let poly_mod = poly_res %% moduloInt
        return poly_mod
    }
}

class EncryptedInteger {
    var c0 : Polynomial
    var c1 : Polynomial
    let context : HECryproModule.Context
    
    init(c0: Polynomial, c1: Polynomial, context: HECryproModule.Context) {
        self.c0 = c0
        self.c1 = c1
        self.context = context
    }
    
    func add(value rhs: EncryptedInteger) -> EncryptedInteger? {
        
        guard self.context.equals(context: rhs.context) else {
            return nil
        }
        
        let c0 = HECryproModule.stripPolynomial(polynomial: (self.c0 + rhs.c0), moduloPolynomial: context.ringPolynomial, moduloInt: context.parameter_q)
        let c1 = HECryproModule.stripPolynomial(polynomial: (self.c1 + rhs.c1), moduloPolynomial: context.ringPolynomial, moduloInt: context.parameter_q)
        
        return EncryptedInteger(c0: c0, c1: c1, context: self.context)
    }
    
    func mult(value rhs: EncryptedInteger, with publicKey: HECryproModule.PublicKey) -> EncryptedInteger? {
        
        guard self.context.equals(context: rhs.context) else {
            return nil
        }
        
        let q2 = Double(context.messageSpace) / Double(context.parameter_q)
        
        let c0_t = ((self.c0 * rhs.c0) * q2).roundP()
        let c0 = HECryproModule.stripPolynomial(polynomial: c0_t, moduloPolynomial: context.ringPolynomial, moduloInt: context.parameter_q)
        
        let c1_t = (((self.c0 * rhs.c1) + (self.c1 * rhs.c0)) * q2).roundP()
        let c1 = HECryproModule.stripPolynomial(polynomial: c1_t, moduloPolynomial: context.ringPolynomial, moduloInt: context.parameter_q)
        
        let c2_t = ((self.c1 * rhs.c1) * q2).roundP()
        let c2 = HECryproModule.stripPolynomial(polynomial: c2_t, moduloPolynomial: context.ringPolynomial, moduloInt: context.parameter_q)
        
        let l = Int(floor(log_b(Double(self.context.parameter_q), Double(self.context.decomposeBase))))
        let decompose_c2 = HECryproModule.baseDecomposition(polynomial: c2, base: Int64(context.decomposeBase), moduloInt: context.parameter_q)
        
        var sum_with_rlk0 : Polynomial = Polynomial(coefficients: [Double](repeating: 0.0, count: publicKey.evaluationKey.rlks0[0].coefficients.count + decompose_c2[0].coefficients.count-1))
        var sum_with_rlk1 = sum_with_rlk0
        for i in 0..<(l + 1) {
            sum_with_rlk0 = sum_with_rlk0 + (publicKey.evaluationKey.rlks0[i] * decompose_c2[i])
            sum_with_rlk1 = sum_with_rlk1 + (publicKey.evaluationKey.rlks1[i] * decompose_c2[i])
        }
        let res_c0 = c0 + sum_with_rlk0
        let res_c1 = c1 + sum_with_rlk1
        
        return EncryptedInteger(c0: res_c0, c1: res_c1, context: self.context)
    }
}

class EncryptedString {
    var code : [EncryptedInteger]
    
    init(code: [EncryptedInteger]) {
        self.code = code
    }
    
}

