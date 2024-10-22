//
//  ViewController.swift
//  DimoLogo
//
//  Created by ty0x2333 on 10/05/2018.
//  Copyright (c) 2018 ty0x2333. All rights reserved.
//

import UIKit
import DimoLogo
import MBProgressHUD

class ViewController: UIViewController {

    @IBOutlet weak var contentView: UIView!
    private let logoView: DimoLogoView = DimoLogoView()
    private let baseLogoSize: CGSize = CGSize(width: 60, height: 60)
    private var logoSize: CGSize {
        return CGSize(width: baseLogoSize.width * CGFloat(sizeSlider.value),
                      height: baseLogoSize.height * CGFloat(sizeSlider.value))
    }
    @IBOutlet weak var sizeSlider: UISlider!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    private let colors: [UIColor] = [.white, .gray, .red, .yellow]
    private var colorIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        logoView.backgroundColor = .black
        logoView.foregroundColor = colors[colorIndex]
        logoView.play()
        contentView.addSubview(logoView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        logoView.frame = CGRect(origin: CGPoint(x: (contentView.bounds.width - logoSize.width) / 2.0,
                                                y: (contentView.bounds.height - logoSize.height) / 2.0), size: logoSize)
    }

    @IBAction func onShowHUD(_ sender: Any) {
        MBProgressHUD.showDimoHUDAdded(to: view, title: nil, animated: true)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { (_) in
            MBProgressHUD.forView(self.view)?.hide(animated: true)
            let hud = MBProgressHUD.showDimoHUDAdded(to: self.view, title: "Nothing", animated: true)
            hud.hide(animated: true, afterDelay: 3.0)
        }
    }

    @IBAction func onSizeChange(_ sender: UISlider) {
        view.setNeedsLayout()
        sizeLabel.text = "Size: \(String(format: "%.1f", sender.value))"
    }

    @IBAction func onProgressChange(_ sender: UISlider) {
        logoView.progress = CGFloat(sender.value)
        progressLabel.text = "Progress: \(String(format: "%.1f", sender.value))"
    }

    @IBAction func onPlay(_ sender: Any) {
        logoView.play()
    }

    @IBAction func onStop(_ sender: Any) {
        logoView.stop()
    }

    @IBAction func onChangeColor(_ sender: Any) {
        colorIndex = (colorIndex + 1) % colors.count
        logoView.foregroundColor = colors[colorIndex]
    }
    @IBAction func onBlockThread(_ sender: Any) {
        sleep(2)
    }
}
