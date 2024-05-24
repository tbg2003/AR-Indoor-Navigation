
import UIKit
import FirebaseDatabase
import Firebase
import FirebaseCore

class UserLoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var UsernameTxt: UITextField!
    
    @IBOutlet weak var PasswordTxt: UITextField!
    
    
    
    private let database = Database.database(url: "https://ar-indoor-navigation-b6d19-default-rtdb.europe-west1.firebasedatabase.app").reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.UsernameTxt.delegate = self
        self.PasswordTxt.delegate = self
        
        database.child("users").child("\(UIDevice.current.identifierForVendor!)").setValue("Entrance")
       
        if homeController.darkModeOn.on == "true"{
            overrideUserInterfaceStyle = .dark
        }else {
            overrideUserInterfaceStyle = .light
            
        }
      
    }
    
    @IBAction func EnterPressed(_ sender: Any) {
        
        if (UsernameTxt.text == "yousef" && PasswordTxt.text == "123") {
            print("works")
            performSegue(withIdentifier: "usertoSelection", sender: nil)
        } else {
            let alertController = UIAlertController(title: "Incorrect", message: "Incorrect Username / Password", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) {
                (action: UIAlertAction!) in
                // Code in this block will trigger when OK button tapped.
                print("Ok button tapped");
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

