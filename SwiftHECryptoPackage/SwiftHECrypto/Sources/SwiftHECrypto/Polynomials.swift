//
//  Polynomials.swift
//  IntegerHomomorphicEncryption
//
//  Created by Nicklas Körtge on 09.04.21.
//  https://rosettacode.org/wiki/Polynomial_synthetic_division#Python

import Foundation

class Polynomial {
    
    var coefficients = [Double]()
    var degree : Int = 0
    
    init(coefficients: [Int64]) {
        self.coefficients = Int_arr_to_double(arr: coefficients)
        self.degree = coefficients.count-1
    }
    
    init(coefficients: [Double]) {
        self.coefficients = coefficients
        self.degree = coefficients.count-1
    }
    
    private func Int_arr_to_double(arr: [Int64]) -> [Double] {
        var d_arr = [Double]()
        
        for value in arr {
            d_arr.append(Double(value))
        }
        
        return d_arr
    }
    
    func floorP() -> Polynomial {
        
        var coef = [Double](repeating: 0.0, count: self.coefficients.count)
        
        for i in 0..<self.coefficients.count {
            coef[i] = floor(self.coefficients[i])
        }
        
        return Polynomial(coefficients: coef)
    }
    
    func roundP() -> Polynomial {
        
        var coef = [Double](repeating: 0.0, count: self.coefficients.count)
        
        for i in 0..<self.coefficients.count {
            coef[i] = round(self.coefficients[i])
        }
        
        return Polynomial(coefficients: coef)
    }
    
}

func ==(lhs: Polynomial, rhs: Polynomial) -> Bool {
    return lhs.coefficients == rhs.coefficients
}

func +(lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    
    let size = max(lhs.coefficients.count, rhs.coefficients.count)
    var coef = [Double](repeating: 0.0, count: size)
    
    for i in 0..<lhs.coefficients.count {
        coef[i] = lhs.coefficients[i]
    }
    
    for j in 0..<rhs.coefficients.count {
        coef[j] += rhs.coefficients[j]
    }
    
    return Polynomial(coefficients: coef)
    
}

func +(lhs: Polynomial, rhs: Double) -> Polynomial {
    
    var coef = [Double](repeating: 0.0, count: lhs.coefficients.count)
    
    for i in 0..<lhs.coefficients.count {
        coef[i] = lhs.coefficients[i] + rhs
    }
    return Polynomial(coefficients: coef)
    
}


func *(lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    
    var coef = [Double](repeating: 0.0, count: lhs.coefficients.count + rhs.coefficients.count - 1)
    
    for i in 0..<lhs.coefficients.count {
        for j in 0..<rhs.coefficients.count {
            coef[i+j] += lhs.coefficients[i] * rhs.coefficients[j]
        }
    }
    return Polynomial(coefficients: coef)
    
}

func *(lhs: Polynomial, rhs: Double) -> Polynomial {
    
    var coef = [Double](repeating: 0.0, count: lhs.coefficients.count)
    
    for i in 0..<lhs.coefficients.count {
        coef[i] = lhs.coefficients[i] * rhs
    }
    return Polynomial(coefficients: coef)
    
}

func /(lhs: Polynomial, rhs: Polynomial) -> (Polynomial, Polynomial)  {
    let res = lhs
    let normalizer = rhs.coefficients[0]
    
    for i in 0..<lhs.coefficients.count - (rhs.coefficients.count - 1) {
        res.coefficients[i] = lhs.coefficients[i] / normalizer
        let coef = res.coefficients[i]
        
        if coef != 0 {
            for j in 1..<rhs.coefficients.count {
                res.coefficients[i+j] += -rhs.coefficients[j] * coef
            }
        }
    }
    
    let separator = res.coefficients.count - (rhs.coefficients.count - 1)
    
    let result = Polynomial(coefficients: Array(res.coefficients[0...separator]))
    let rest = Polynomial(coefficients: Array(res.coefficients[separator...res.coefficients.count-1]))
    
    return (result, rest)
}

func /(lhs: Polynomial, rhs: Double) -> (Polynomial)  {
    
    var coef = [Double](repeating: 0.0, count: lhs.coefficients.count)
    
    for i in 0..<lhs.coefficients.count {
        coef[i] = lhs.coefficients[i] / rhs
    }
    return Polynomial(coefficients: coef)
}

func powP(lhs: Polynomial, rhs: Int) -> Polynomial {
    
    guard rhs > 0 else {
        fatalError()
    }
    
    var res = lhs
    
    for _ in 1..<rhs {
        res = res * lhs
    }
    
    return res
}

func %%(lhs: Polynomial, rhs: Int64) -> Polynomial {
    var coef = [Double](repeating: 0.0, count: lhs.coefficients.count)
    
    for i in 0..<lhs.coefficients.count {
        coef[i] = Double(Int64(lhs.coefficients[i]) %% rhs)
    }
    return Polynomial(coefficients: coef)
}


func createPolynomial(of size: Int, in range: ClosedRange<Int64>) -> Polynomial {
    let coef = (1...size).map( {_ in Int64.random(in: range)})
    return Polynomial(coefficients: coef)
}

func createPolynomial(of size: Int, with distribution: Distribution) -> Polynomial {
    let coef = (1...size).map( {_ in distribution.getSample()})
    return Polynomial(coefficients: coef)
}
