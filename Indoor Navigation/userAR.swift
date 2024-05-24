
import UIKit
import ARKit
import FirebaseStorage
import Firebase


class userAR: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!

    var place = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        configureLighting()
        addTapGestureToSceneView()
        
        place = DestinationPickerUser.something.selected
        
        
        Task { @MainActor in
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            let ref = try await storageRef.child("World\(place)").downloadURL()
            
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
    
  
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didReceiveTapGesture(_:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didReceiveTapGesture(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        guard let hitTestResult = sceneView.hitTest(location, types: [.featurePoint, .estimatedHorizontalPlane]).first
            else { return }
        let anchor = ARAnchor(transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: anchor)
    }
    
    func generateSphereNode() -> SCNNode {
        let sphere = SCNSphere(radius: 0)
        let sphereNode = SCNNode()
        sphereNode.position.y += Float(sphere.radius)
        sphereNode.geometry = sphere
        return sphereNode
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
    
    @IBAction func resetBarButtonItemDidTouch(_ sender: UIBarButtonItem) {
        resetTrackingConfiguration()
    }
    
    @IBAction func saveBarButtonItemDidTouch(_ sender: UIBarButtonItem) {
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            guard let worldMap = worldMap else {
                return self.setLabel(text: "Error getting current world map.")
            }
            
            do {
                try self.archive(worldMap: worldMap)
                DispatchQueue.main.async {
                    self.setLabel(text: "World map is saved.")
                }
            } catch {
                fatalError("Error saving world map: \(error.localizedDescription)")
            }
        }
    }
  
    
    @IBAction func loadBarButtonItemDidTouch(_ sender: UIBarButtonItem) {
        
    }
    
    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        if let worldMap = worldMap {
            configuration.initialWorldMap = worldMap
            setLabel(text: "Found saved world map.")
        } else {
            setLabel(text: "Move camera around to map your surrounding space.")
        }
        
        sceneView.debugOptions = [.showFeaturePoints, .showSkeletons, .showBoundingBoxes, .showPhysicsShapes]
        sceneView.session.run(configuration, options: options)
    }
    
    func setLabel(text: String) {
        label.text = text
    }
    
   
    
    
    func archive(worldMap: ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: ViewController.something.worlds[place] as! URL, options: [.atomic])
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
        return worldMap
    }
    
    func unarchive1(worldMapData data: Data) -> ARWorldMap? {
        guard let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
            let worldMap = unarchievedObject else { return nil }
        return worldMap
    }
    
    @IBAction func Des1(_ sender: Any) {
        place = 0
    }
    @IBAction func Des2(_ sender: Any) {
        place = 1
    }
    @IBAction func Des3(_ sender: Any) {
        place = 2
    }
    
}


extension userAR: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard !(anchor is ARPlaneAnchor) else { return }

        let sphereNode = generateSphereNode()
        DispatchQueue.main.async {
            node.addChildNode(sphereNode)
        }
    }
    
}

