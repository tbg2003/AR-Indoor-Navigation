
import UIKit
import AVKit
import AVFoundation




class homeController: UIViewController {
    
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    struct home {
        static var userAdmin = false
    }
    struct darkModeOn{
        static var on = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playBackgroundVideo()
    }
    
    @IBAction func helpButton(_ sender: Any) {
        gifController.helpVar.user = 0
    }
    
    func playBackgroundVideo() {
               let fileUrl = Bundle.main.url(forResource: "menuBackground", withExtension: "mov")!
               let asset = AVAsset(url: fileUrl)
               let item = AVPlayerItem(asset: asset)

               let player = AVQueuePlayer()
               playerLayer.player = player
               playerLayer.videoGravity = .resizeAspectFill
                view.layer.insertSublayer(playerLayer, at: 0)
               playerLooper = AVPlayerLooper(player: player, templateItem: item)
               player.play()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewDidLayoutSubviews() {
        playerLayer.frame = view.bounds
    }
    
    @IBAction func adminBtn(_ sender: Any) {
        home.userAdmin = true
    }
    
    @IBAction func userBtn(_ sender: Any) {
        home.userAdmin = false
    }
    
    
}
