//
//  ViewController.swift
//  DimoLogo
//
//  Created by luckytianyiyan on 10/05/2018.
//  Copyright (c) 2018 luckytianyiyan. All rights reserved.
//

import UIKit
import DimoLogo

class ViewController: UIViewController {
    
    private let logoView: DimoLogoView = DimoLogoView()
    private let logoSize: CGSize = CGSize(width: 60, height: 60)
    private let colors: [UIColor] = [.white, .gray, .red, .yellow]
    private var colorIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        logoView.backgroundColor = .black
        logoView.foregroundColor = colors[colorIndex]
        logoView.play()
        view.addSubview(logoView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        logoView.frame = CGRect(origin: CGPoint(x: (view.bounds.width - logoSize.width) / 2.0, y: (view.bounds.height - logoSize.height) / 2.0), size: logoSize)
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

