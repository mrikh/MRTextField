//
//  ViewController.swift
//  MRTextField
//
//  Created by Mayank Rikh on 02/12/17.
//  Copyright © 2017 Mayank Rikh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var mrTextField: MRTextField!
    @IBOutlet weak var showError: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mrTextField.regexString = "^(?=.*[A-Za-z])(?=.*?[0-9])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}$"
        mrTextField.errorString = "HAHAHAHAHAHHA"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func showError(_ sender: UIButton) {
        
        mrTextField.showErrorMessage()
    }
    
    
    @IBAction func hideError(_ sender: UIButton) {
        
        mrTextField.hideErrorMessage()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
    }
}

