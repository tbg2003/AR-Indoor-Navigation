//
//  CommonPlaceViewController.swift
//  Indoor Navigation
//
//  Created by zishuo on 2023/3/10.
//


import UIKit

class CommonPlacesViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if homeController.darkModeOn.on == "true"{
            overrideUserInterfaceStyle = .dark
        }else {
            overrideUserInterfaceStyle = .light
            
        }
        
    }
    
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
