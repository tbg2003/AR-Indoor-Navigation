
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import FirebaseCore

class DestinationPicker: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    private let database = Database.database(url: "https://ar-indoor-navigation-b6d19-default-rtdb.europe-west1.firebasedatabase.app").reference()
    
    
    struct something {
        static var selected = 0
        static var destination  = ""
        static var textSelected = ""
        static var pickerData: [String] = [String]()
        static var isNewworld = false
        static var listNum = 0
    }

    var timer = Timer()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if homeController.darkModeOn.on == "true"{
            overrideUserInterfaceStyle = .dark
        }else {
            overrideUserInterfaceStyle = .light
            
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateList), userInfo: nil, repeats: true)
        
        DestinationPicker.something.pickerData = ["Select a destination"]
        
       
        
        let storageReference = Storage.storage().reference()
        storageReference.listAll { (result, error) in
          if let error = error {
          
          }
         for prefix in result!.prefixes {
 
          }
          for item in result!.items {
              DestinationPicker.something.pickerData.append(item.name)
              DispatchQueue.main.async {
                  self.pickerView.reloadAllComponents()
              }
          }
        }
        

    }
    
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
          return 1
      }
      
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
          return DestinationPicker.something.pickerData.count;
      }
      
      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
          if(something.isNewworld==false){
              DestinationPicker.something.textSelected = DestinationPicker.something.pickerData[row]
              DestinationPicker.something.destination = DestinationPicker.something.pickerData[row]
          }
          return DestinationPicker.something.pickerData[row] as String
      }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        something.selected = row-1
    }
    
    @objc func buttonAction(_ sender:UIButton!) {
       print("Button tapped")
    }
    
    
    @IBAction func helpBtn(_ sender: Any) {
        gifController.helpVar.user = 2
    }
    @IBAction func settingsBtn(_ sender: Any) {
        SettingsController.settingsVar.user = 2
    }
    @IBAction func signoutBack(_ sender: Any) {
        let firebaseAuth = Auth.auth()
     do {
       try firebaseAuth.signOut()
     } catch let signOutError as NSError {
       print("Error signing out: %@", signOutError)
     }
    }
    
    @objc func updateList() {
        self.pickerView.reloadAllComponents()
    }
    
    @IBAction func DeleteButton(_ sender: Any) {
        let ref = Storage.storage().reference().child("\(DestinationPicker.something.textSelected)")

        // Delete the file
        ref.delete { error in
          if let error = error {
            // Uh-oh, an error occurred!
          } else {
            // File deleted successfully
              let alertController = UIAlertController(title: "Delete Destination", message: "Destination deleted succesfully!", preferredStyle: .alert)
              let OKAction = UIAlertAction(title: "OK", style: .default) {
                  (action: UIAlertAction!) in
                  self.pickerView.reloadAllComponents()
              }
              alertController.addAction(OKAction)
              self.present(alertController, animated: true, completion: nil)
              DestinationPicker.something.pickerData.remove(at: something.selected+1)
              self.pickerView.reloadAllComponents()
          }
        }
         
    }
    @IBAction func chooseBtn(_ sender: Any) {
        something.isNewworld = false
        if (pickerView.selectedRow(inComponent: 0) == 0) {
            let alertController = UIAlertController(title: "Error", message: "Please select a route!", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) {
                (action: UIAlertAction!) in
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            performSegue(withIdentifier: "admintoAR", sender: nil)
        }
        
            
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func newWorld(_ sender: Any) {
        something.isNewworld = true
        
        something.listNum = DestinationPicker.something.pickerData.count
        
        let alert = UIAlertController(title: "New World", message: "Please type the routes name", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            //textField.text = "Some default text"
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            DestinationPicker.something.textSelected = textField!.text!
            DestinationPicker.something.destination = textField!.text!
            self.performSegue(withIdentifier: "admintoAR", sender: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) {
            UIAlertAction in
        })

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
}
