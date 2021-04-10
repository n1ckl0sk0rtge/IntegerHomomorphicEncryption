//
//  ViewController.swift
//  IntegerHomomorphicEncryption
//
//  Created by Nicklas Körtge on 01.04.21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    let helib = HECryproModule()
    
    @IBAction func clicked(_ sender: Any) {
        
        let (pk, sk) = helib.createKeypair()
        
        let enc1 = helib.encrypt(message: 20, with: pk)
        
        let enc2 = helib.encrypt(message: 3, with: pk)
        
        let enc3 = helib.encrypt(message: 2, with: pk)
        
        if let erg = enc1.add(value: enc2)?.mult(value: enc3, with: pk) {
            
            let dec = helib.decrypt(cipher: erg, with: sk)
            
            print("\(dec)")
            
        }
        
        let message = helib.encrypt(message: "hallo world!", with: pk)
        
        if let dec_mes = helib.decrypt(cipher: message, with: sk) {
            print(dec_mes)
        }

        
    }
    


}

