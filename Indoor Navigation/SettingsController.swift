
import UIKit

class SettingsController: UIViewController {
    
    struct settingsVar {
        static var user = 0
    }
    
   
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    override func viewDidAppear(_ animated: Bool) {
        switch traitCollection.userInterfaceStyle {
                case .light, .unspecified:
            print("no")
            darkModeSwitch.isOn = false
                case .dark:
            print("yes")
            darkModeSwitch.isOn = true
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if homeController.darkModeOn.on == "true"{
            overrideUserInterfaceStyle = .dark
        }else {
            overrideUserInterfaceStyle = .light
        }
      
    }
    @IBAction func backBtn(_ sender: Any) {
        if(SettingsController.settingsVar.user == 0) {
            performSegue(withIdentifier: "settingsToHome", sender: nil)
        } else if(SettingsController.settingsVar.user == 1) {
            performSegue(withIdentifier: "settingsToUser", sender: nil)
        } else {
            performSegue(withIdentifier: "settingsToAdmin", sender: nil)
        }
    }
    @IBAction func darkMode(_ sender: UISwitch) {
        
        if sender.isOn{
            homeController.darkModeOn.on = "true"
        }else{
            homeController.darkModeOn.on = "false"
        }
       
    }
}
