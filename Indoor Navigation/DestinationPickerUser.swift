
import UIKit
import Firebase
import FirebaseStorage
import FirebaseCore

class DestinationPickerUser: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    struct something {
        static var selected = 0
        static var pickerData: [String] = [String]()
        static var textSelected = ""
    }
    
    @IBAction func settingsUser(_ sender: Any) {
        SettingsController.settingsVar.user = 1
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DestinationPickerUser.something.pickerData.removeAll()
        if homeController.darkModeOn.on == "true"{
            overrideUserInterfaceStyle = .dark
        }else {
            overrideUserInterfaceStyle = .light
            
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        DestinationPickerUser.something.pickerData = ["Select a destination"]
        
        let storageReference = Storage.storage().reference()
        storageReference.listAll { (result, error) in
          if let error = error {
          
          }
            for prefix in result!.prefixes {
 
          }
          for item in result!.items {
              DestinationPickerUser.something.pickerData.append(item.name)
              DispatchQueue.main.async {
                  self.pickerView.reloadAllComponents()
              }
          }
        }
    }
    
    @IBAction func helpBtn(_ sender: Any) {
        gifController.helpVar.user = 1
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
          return 1
      }
    
      func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
          return DestinationPickerUser.something.pickerData.count;
      }
      
      func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
          DestinationPickerUser.something.textSelected = DestinationPickerUser.something.pickerData[row]
          return  DestinationPickerUser.something.pickerData[row] as String
      }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent  component: Int) {
        something.selected = row-1
    }
    
    
    @IBAction func chooseBtn(_ sender: Any) {
        if something.selected == -1 {
            let alertController = UIAlertController(title: "Destination", message: "Please pick a destination", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) {
                (action: UIAlertAction!) in
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            performSegue(withIdentifier: "usertoAR", sender: nil)
        }
    }
    
    
}
