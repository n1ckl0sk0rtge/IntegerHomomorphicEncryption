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
    
    let heModule = HECryproModule()
    
    @IBAction func clicked(_ sender: Any) {
        
        let (pk, sk) = heModule.createKeypair()
        
        let enc1 = heModule.encrypt(message: 20, with: pk)
        
        let enc2 = heModule.encrypt(message: 3, with: pk)
        
        let enc3 = heModule.encrypt(message: 2, with: pk)
        
        if let erg = (enc1 + enc2)?.mult(value: enc3, with: pk) {
            
            let dec = heModule.decrypt(cipher: erg, with: sk)
            
            print("\(dec)")
            
        }
        
        let message = heModule.encrypt(message: "hallo world!", with: pk)
        
        if let dec_mes = heModule.decrypt(cipher: message, with: sk) {
            print(dec_mes)
        }

        
    }
    


}

