//
//  ViewController.swift
//  MarioVideoPlayer
//
//  Created by ouchkemvanra on 01/06/2022.
//  Copyright (c) 2022 ouchkemvanra. All rights reserved.
//

import UIKit
import MarioVideoPlayer

class ViewController: UIViewController, PlayerDelegate, PlayerOptionSelectionDelegate {
    
    let speedOption : PlayerOption = .init(id: "1", icon: .init(named: "settings")!, title: "Speed")
    let qualityOption : PlayerOption =  .init(id: "2", icon: .init(named: "settings")!, title: "Quality")
    
    let slowSpeedOpt: PlayerOption =  .init(id: "11", icon: .init(named: "settings")!, title: "Slow Speed")
    let normalSpeedOpt: PlayerOption =  .init(id: "12", icon: .init(named: "settings")!, title: "Normal Speed")
    let fastSpeedOpt: PlayerOption =  .init(id: "13", icon: .init(named: "settings")!, title: "Fast Speed")
    
    let lowQualityOpt: PlayerOption =  .init(id: "21", icon: .init(named: "settings")!, title: "Low Quality")
    let normalQualityOpt: PlayerOption =  .init(id: "22", icon: .init(named: "settings")!, title: "Normal Quality")
    let highQualityOpt: PlayerOption =  .init(id: "23", icon: .init(named: "settings")!, title: "High Quality")
    
    func didTapOnOption() {
        // To do: show option
        let vc = OptionViewController.init(data: [speedOption, qualityOption])
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    func didFinishPlaying() {
        // To do: player did finish
    }
    
    lazy var player: MarioVideoPlayerView = {
        let v = MarioVideoPlayerView.init()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        v.isAutoPlay = true
        return v
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan
        view.addSubview(player)

        
        NSLayoutConstraint.activate([
            player.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            player.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            player.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            player.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 9/16),
            
        ])
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        player.setPlayer(list: [.init(link: "https://eschool-video.sabay.com/video/G8/Mathematics/5ec265d981768d317075244c-1_360.mp4", title: "360", qualityList: [.init(link: "https://eschool-video.sabay.com/video/G8/Mathematics/5ec265d981768d317075244c-1_360.mp4", quality: "360"), .init(link: "https://eschool-video.sabay.com/video/G8/Mathematics/5ec265d981768d317075244c-1_720.mp4", quality: "720")]), .init(link: "https://eschool-video.sabay.com/video/G8/Mathematics/5ec265d981768d317075244c-1_720.mp4", title: "720", qualityList: [.init(link: "https://eschool-video.sabay.com/video/G8/Mathematics/5ec265d981768d317075244c-1_360.mp4", quality: "360"), .init(link: "https://eschool-video.sabay.com/video/G8/Mathematics/5ec265d981768d317075244c-1_720.mp4", quality: "720")])])
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIDevice.current.orientation != .portrait{
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
//            UIApplication.shared.statusBarOrientation = .portrait
        }
    }
    func optionSelected(_ option: PlayerOption) {
        switch option.id{
            case "1":
                showSpeedOption()
                break
            case "2":
                showQualityOption()
                break
            case "11":
                player.changeSpeed(type: .slow)
                break
            case "12":
                player.changeSpeed(type: .normal)
                break
            case "13":
                player.changeSpeed(type: .fast)
                break
            case "21":
                player.changeQuality(type: .low)
                break
            case "22":
                player.changeQuality(type: .normal)
                break
            case "23":
                player.changeQuality(type: .high)
                break
            default:
                break
        }
    }
    private func showSpeedOption(){
        let vc = OptionViewController.init(data: [slowSpeedOpt, normalSpeedOpt, fastSpeedOpt])
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    private func showQualityOption(){
        let vc = OptionViewController.init(data: [lowQualityOpt, normalQualityOpt, highQualityOpt])
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
}

extension UIView{
    func topConstraint() -> NSLayoutConstraint?{
        let top = self.constraints.filter({ $0.firstAttribute == .top})
        return top.last
    }
}
