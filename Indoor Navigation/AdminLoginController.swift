
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AdminLoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var adminUsernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.adminUsernameTxt.delegate = self
        self.passwordTxt.delegate = self
        if homeController.darkModeOn.on == "true"{
            overrideUserInterfaceStyle = .dark
        }else {
            overrideUserInterfaceStyle = .light
            
        }
      
    }
    
    
    @IBAction func LoginPressed(_ sender: Any) {
        
        guard let email = adminUsernameTxt.text, !email.isEmpty,
              let password = passwordTxt.text, !password.isEmpty else {
            let alertController = UIAlertController(title: "Error", message: "Please type in an email/password", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) {
                (action: UIAlertAction!) in
                // Code in this block will trigger when OK button tapped.
                
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
       
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            guard error == nil else {
                let alertController = UIAlertController(title: "Incorrect", message: "Incorrect Username / Password", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) {
                    (action: UIAlertAction!) in
                    // Code in this block will trigger when OK button tapped.
                    
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            self.performSegue(withIdentifier: "admintoCamera", sender: nil)
        }
        
        /*
        
        if (adminUsernameTxt.text == "yousef" && passowrdTxt.text == "123") {
            
            
        } else {
            let alertController = UIAlertController(title: "Incorrect", message: "Incorrect Username / Password", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) {
                (action: UIAlertAction!) in
                // Code in this block will trigger when OK button tapped.
                
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        }
         
         */
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
}
