//
//  SetNameViewController.swift
//  Mac-Bluetooth-iOS
//
//  Created by Ramneet on 04/05/20.
//  Copyright © 2020 Ramneet. All rights reserved.
//

import UIKit

class SetNameViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func searchAndConnect(_ sender: UIButton) {
        
        if textField.text != ""{
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
            nextViewController.name = textField.text ?? ""
            self.present(nextViewController, animated:true, completion:nil)
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
