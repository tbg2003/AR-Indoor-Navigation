
import UIKit
import ARKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import Vision


class ViewController: UIViewController {

    
    @IBOutlet weak var sceneView: ARSCNView!

    @IBOutlet weak var loadBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    
    private let database = Database.database(url: "https://ar-indoor-navigation-b6d19-default-rtdb.europe-west1.firebasedatabase.app").reference()

    
    var worldMapDistance: ARWorldMap? = nil
    
    var calculateDistanceBool = false
    
    var mapLoaded = false
    
    var distance: Float?
    
    var HighestDistance: Float = 0.0
    
    var anchorPosition: simd_float4 = simd_float4(1000.0, 1000.0, 1000.0, 1000.0)
    
    var loopDone = false
    
    var AllNodes: [SCNNode]?
    
    var numNodes = 1
    
    let configuration = ARWorldTrackingConfiguration()
    
    var place = 0
    
    var timer = Timer()
    
    struct something {
        static var worlds = [URL]()
        static var worldMapURL: URL?
        static var worldURL :  String?
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        sceneView.delegate = self
        
        distance = 10000.0
        
        instructionLabel.numberOfLines = 0
        
        
        /// Create a new reference image from a CGImage
        ///
        /*
        if let qrCodeReferenceImage = UIImage(named: "QRCode1")?.cgImage {
            var qrCodeReferenceImageSet = ARReferenceImage.referenceImages(inGroupNamed: "QRCode", bundle: nil)!
            let newReferenceImage = ARReferenceImage(qrCodeReferenceImage, orientation: .up, physicalWidth: 0.1)
            qrCodeReferenceImageSet.insert(newReferenceImage)
            configuration.detectionImages = qrCodeReferenceImageSet
        }
        */
                // Run the configuration on the ARSceneView
                //sceneView.session.run(configuration)
        
        
        
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(ChangeLabelState), userInfo: nil, repeats: true)
        
        configureLighting()
        if homeController.home.userAdmin == true {
            addTapGestureToSceneView()
            
            instructionLabel.isHidden = true
        } else {
            saveBtn.isHidden = true
            loadBtn.isHidden = true
            resetBtn.isHidden = true
        
        }
        
        if homeController.darkModeOn.on == "true"{
            overrideUserInterfaceStyle = .dark
        }else {
            overrideUserInterfaceStyle = .light
            
        }
        
        if(DestinationPicker.something.isNewworld == true) {
            
            place = DestinationPicker.something.listNum
        } else {
            place = DestinationPicker.something.selected
        }
        
        
        
        for i in 0...100 {
            something.worldMapURL = {
            do {
                return try FileManager.default.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
                    .appendingPathComponent("worldMapURL\(i)")
            } catch {
                fatalError("Error getting world map URL from document directory.")
            }
        }()

            something.worlds.append(something.worldMapURL!)
            do {
                try FileManager.default.removeItem(at: something.worldMapURL!)
            } catch {
                print(error)
            }
        }
        
        
        if(homeController.home.userAdmin == false) {
            Task { @MainActor in
                
                let storage = Storage.storage()
                let storageRef = storage.reference()
                
                let ref = try await storageRef.child("\(DestinationPickerUser.something.textSelected)").downloadURL()
                
                let fireUrl = URL(string: "\(ref)")!
                
                print(fireUrl)
                
                guard let worldMapData = retrieveWorldMapData(from: fireUrl),
                      let worldMap = unarchive(worldMapData: worldMapData) else { return }
                resetTrackingConfiguration(with: worldMap)
                
                /*
                 guard let worldMapData = retrieveWorldMapData(from: something.worlds[place]),
                 let worldMap = unarchive(worldMapData: worldMapData) else { return }
                 resetTrackingConfiguration(with: worldMap) */
            }
        }
        
    }


    
 
    
    @objc func ChangeLabelState() {
        
        
        
        if(worldMapDistance != nil) {
        
            sceneView.pointOfView?.camera?.zFar = 4
            
            
            if(homeController.home.userAdmin == false && calculateDistanceBool == true) {
               
                let camPosition =  sceneView.session.currentFrame?.camera.transform.columns.3
                
                var currentDistance: Float
                
                for i in 0...(worldMapDistance?.anchors.count)!-1 {
                    
                    currentDistance = simd_distance((worldMapDistance?.anchors[i].transform.columns.3)!, camPosition!)
                    
                    if(currentDistance >= HighestDistance) {
                        HighestDistance = currentDistance
                        anchorPosition = (worldMapDistance?.anchors[i].transform.columns.3)!
                    }
                    
                   
                }
    
                    distance = simd_distance(camPosition!, anchorPosition)
            
            }
        
           // label.text = "\(distance)"
            
           // print("\(distance)")
            
           
            
            
            if(distance! <= 2.5) {
               
                instructionLabel.isHidden = false
                instructionLabel.text = "Distination Reached!"
                instructionLabel.backgroundColor = .green
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    self.worldMapDistance = nil
                    self.performSegue(withIdentifier: "backtouser", sender: nil)
                }
            } else {
                instructionLabel.backgroundColor = .transparentWhite
            }
        
        }
        
        if(mapLoaded == true && homeController.home.userAdmin == false) {
            instructionLabel.text = "Route loaded!"
        
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                self.instructionLabel.isHidden = true
                self.mapLoaded = false
            }
        }
        
    }
    
   
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didReceiveTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        guard let hitTestResult = sceneView.hitTest(location, types: [.existingPlane]).first
            else { return }
        
        let anchor = ARAnchor(transform: hitTestResult.worldTransform)
        
        sceneView.session.add(anchor: anchor)

    }
    
    func generateSphereNode() -> SCNNode {
        
        let tempScene = SCNScene(named: "ARObj.scnassets/Arrow.scn")!
        let modelNode = tempScene.rootNode
          // modelNode.simdPosition = float3(0, 0, 0.5)
           //sceneView.scene.rootNode.addChildNode(modelNode)
            modelNode.scale = SCNVector3(0.05, 0.05, 0.05)
            return modelNode
         
        /*
        let sphere = SCNSphere(radius: 0.05)
                let sphereNode = SCNNode()
                sphereNode.position.y += Float(sphere.radius)
                sphereNode.position.y += Float(sphere.radius)
                sphereNode.geometry = sphere
                return sphereNode
        
        */
    }
    
    func uploadFile(fileUrl: URL, fileName: String) {
      do {
        // Create file name
        let fileExtension = fileUrl.pathExtension
        let fileName = "\(fileName)\(fileExtension)"

        let storageReference = Storage.storage().reference().child(fileName)
        let currentUploadTask = storageReference.putFile(from: fileUrl) { (storageMetaData, error) in
          if let error = error {
              print("FileExentation: \(fileExtension)")
              print("FileName: \(fileName)")
            print("Upload error: \(error.localizedDescription)")
            return
          }
                                                                                    
                                                                                    
          storageReference.downloadURL { (url, error) in
            if let error = error  {
              print("Error on getting download url: \(error.localizedDescription)")
              return
            }
          }
        }
      } catch {
        print("Error on extracting data from url: \(error.localizedDescription)")
      }
    }
    
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTrackingConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

    
    @IBAction func resetButtonItemDidTouch(_ sender: Any) {
        resetTrackingConfiguration()
    }
    
    @IBAction func saveButtonItemDidTouch(_ sender: Any) {
    
        if homeController.home.userAdmin == true {
            sceneView.session.getCurrentWorldMap { (worldMap, error) in
                guard let worldMap = worldMap else {
                    return self.setLabel(text: "Error getting current world map.")
                }
                
                do {
                    try self.archive(worldMap: worldMap)
                    DispatchQueue.main.async {
                        self.setLabel(text: "World map is saved.")
                        let alert = UIAlertController(title: "World", message: "World saved!", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Okay", style: .cancel) {
                            UIAlertAction in
                        })

                        // 4. Present the alert.
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                } catch {
                    fatalError("Error saving world map: \(error.localizedDescription)")
                }
            }
        }
    }
    
   
  
    @IBAction func loadButtonItemDidTouch(_ sender: Any) {
        print(DestinationPicker.something.textSelected)
        Task { @MainActor in
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let ref = try await storageRef.child("\(DestinationPicker.something.textSelected)").downloadURL()
            
            let fireUrl = URL(string: "\(ref)")!
            
            
            guard let worldMapData = retrieveWorldMapData(from: fireUrl),
                  let worldMap = unarchive(worldMapData: worldMapData) else { return }
            resetTrackingConfiguration(with: worldMap)
            
            
             /*
             guard let worldMapData = retrieveWorldMapData(from: something.worlds[place]),
             let worldMap = unarchive(worldMapData: worldMapData) else { return }
             resetTrackingConfiguration(with: worldMap)
             */
        }
    }
    
  
    
    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
        
        configuration.planeDetection = [.horizontal]
       
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        if let worldMap = worldMap {
            configuration.initialWorldMap = worldMap
            setLabel(text: "Found saved world map.")
            instructionLabel.text = "Connected to Server!"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.instructionLabel.text = "Move camera around near by objects"
            }
            
        } else {
            setLabel(text: "Move camera around to map your surrounding space.")
        }
        
        
        
        sceneView.debugOptions = [.showFeaturePoints, .showSkeletons, .showBoundingBoxes, .showPhysicsShapes]
        sceneView.session.run(configuration, options: options)
        
        
    }
    
    func setLabel(text: String) {
       // label.text = text
    }
    
    
    
    
    func archive(worldMap: ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: something.worlds[place] as! URL, options: [.atomic])
        uploadFile(fileUrl: something.worlds[place], fileName: "\(DestinationPicker.something.destination)")
        print(DestinationPicker.something.destination)
    }
    
    func retrieveWorldMapData(from url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        } catch {
            self.setLabel(text: "Error retrieving world map data.")
            return nil
        }
    }
    
    
    func unarchive(worldMapData data: Data) -> ARWorldMap? {
        guard let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
            let worldMap = unarchievedObject else { return nil }
        worldMapDistance = worldMap
        return worldMap
    }
    
    
    @IBAction func backbtn(_ sender: Any) {
        if homeController.home.userAdmin == true {
            performSegue(withIdentifier: "backtoadmin", sender: nil)
        } else {
            performSegue(withIdentifier: "backtouser", sender: nil)
        }
    }
    
}


extension ViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let transform = frame.camera.transform
        let position = transform.columns.3
        //print(position.x, position.y, position.z)     // UPDATING
      
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        /*
        guard let imageAnchor = anchor as? ARImageAnchor else { return }

               // Check if the detected image is a QR code
               if let referenceImageName = imageAnchor.referenceImage.name, referenceImageName.hasPrefix("QRCode1") {

                   // Optional: do something when a QR code is detected
                   print("QR code detected: \(referenceImageName)")
                   
               }
         */
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard !(anchor is ARPlaneAnchor) else { return }

        let sphereNode = generateSphereNode()
        
        DispatchQueue.main.async {
        
        }
        
        node.addChildNode(sphereNode)
            for i in 4...sceneView.scene.rootNode.childNodes.count-1 {
                if(i != sceneView.scene.rootNode.childNodes.count-1) {
                    let lookAtConstraints = SCNLookAtConstraint(target: sceneView.scene.rootNode.childNodes[i+1])
                    sceneView.scene.rootNode.childNodes[i].constraints = [lookAtConstraints]
                }
            }
        
        if(homeController.home.userAdmin == false ) {
            sceneView.debugOptions = []
        }
        
        mapLoaded = true
        
        calculateDistanceBool = true
    }
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        print(float3(translation.x, translation.y, translation.z))
        return float3(translation.x, translation.y, translation.z)
    }
}

extension UIColor {
    open class var transparentWhite: UIColor {
        return UIColor.white.withAlphaComponent(0.70)
    }
}
