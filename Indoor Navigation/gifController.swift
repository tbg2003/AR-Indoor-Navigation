//
//  gifController.swift
//  Indoor Navigation
//
//  Created by Rosie Gomez on 27/01/2023.
//


import UIKit
import AVKit
import AVFoundation
import SwiftUI



class gifController: UIViewController {
    
    
    
    @IBOutlet weak var imageSteps: UIImageView!
    
    @IBOutlet weak var pageDots: UIPageControl!
    
    @IBOutlet weak var imageText: UILabel!
    
    private var currentIndex = 0
    
    struct helpVar{
        static var user = 0
    }
    
    
    
    let images: [String] = ["ChooseDest", "ConnServer", "ScanWorld", "FollowRoute"]
    let descriptions : [String] = ["Scroll on the destination selector. Hover over desired location. Click 'Choose Dest' ",
                                   "Wait for the app to connect to server, this may take some time depending on wifi strength", "Move camera around at the starting location to scan 3D objects, keep scanning until 'World Loaded' appears. Beaware that the screen may freeze for a few seconds until the route is loaded.", "Follow the arrows accordingly, arrows will keep appearing until you reach the desitnation."]
   
    
    let adminImages: [String] = ["a_NewDest", "a_ScanFP", "a_CreateRoute"]
    let adminDescriptions : [String] = ["To create new destination: Click on 'New Dest', Type in a name of route in format: 'Start location to End location'",                                  "Scan around the start location enviroment, try to scan static 3D objects. You want to scan as many 'feature points' as possible, i.e see as many yellow dots",
                                        "Once you have a good scan, start to create the route, tap on the screen to create an arrow, the arrows will align themselves to the next pressed arrow"]
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
            if homeController.darkModeOn.on == "true"{
                overrideUserInterfaceStyle = .dark
                pageDots.currentPageIndicatorTintColor = UIColor.red
                pageDots.pageIndicatorTintColor = UIColor.white
    
                
            }else {
                overrideUserInterfaceStyle = .light
                pageDots.pageIndicatorTintColor = UIColor.black
            }
        
        display()
        
        imageText.lineBreakMode = NSLineBreakMode.byWordWrapping
        imageText.numberOfLines = 0
        imageText.preferredMaxLayoutWidth = 500
    }
    
    
    func display(){
        if gifController.helpVar.user == 2{
            pageDots.numberOfPages = adminImages.count
            //imageSteps.image = UIImage(named: adminImages[currentIndex])
            imageSteps.loadGif(name: adminImages[currentIndex])
            imageText.text = adminDescriptions[currentIndex]
            pageDots.currentPage = currentIndex
            
        }else{
            pageDots.numberOfPages = images.count
            imageSteps.loadGif(name: images[currentIndex])
            imageText.text = descriptions[currentIndex]
            pageDots.currentPage = currentIndex
        }
        
    }
    
    @IBAction func backBTN(_ sender: Any) {
        print(gifController.helpVar.user)
        if(gifController.helpVar.user == 0) {
            performSegue(withIdentifier: "helpToHome", sender: nil)
        } else if(gifController.helpVar.user == 1) {
            performSegue(withIdentifier: "helpToUser", sender: nil)
        } else {
            performSegue(withIdentifier: "helpToAdmin", sender: nil)
        }
    }
    @IBAction func RightSwipe(_ sender: Any) {
        //print("right swipe")
        if self.currentIndex - 1 == -1{
            if gifController.helpVar.user == 2{
                self.currentIndex = (self.adminImages.count) - 1
                display()
                pageDots.currentPage = currentIndex}
            else{
                self.currentIndex = (self.images.count) - 1
                display()
                pageDots.currentPage = currentIndex}
            
        }else{
            self.currentIndex = self.currentIndex - 1
            display()
        }
    }
        
    
    @IBAction func LeftSwipe(_ sender: Any) {
        print("left swipe")
        if gifController.helpVar.user == 2{
            if self.currentIndex + 1 == self.adminImages.count{
                self.currentIndex = 0
                display()
            }else{
                self.currentIndex += 1
                display()
            }
        }else{ if self.currentIndex + 1 == self.images.count{
            self.currentIndex = 0
            display()
        }else{
            self.currentIndex += 1
            display()
        }
            
        }
        
       
    }
}
