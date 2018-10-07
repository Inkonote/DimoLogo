//
//  HUD.swift
//  DimoLogo
//
//  Created by luckytianyiyan on 2018/10/5.
//

import Foundation
import MBProgressHUD

private class DimoHUD: UIView {
    
    var logoView: DimoLogoView = DimoLogoView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    var textLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        addSubview(logoView)
        logoView.play()
        
        textLabel.font = UIFont.systemFont(ofSize: 13)
        textLabel.textColor = UIColor.white
        addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 116, height: 116)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        logoView.frame = CGRect(x: (bounds.width - 60) / 2.0, y: 16, width: 60, height: 60)
        textLabel.sizeToFit()
        let textWidth = min(bounds.width - 12.0, textLabel.bounds.width)
        textLabel.frame = CGRect(x: (bounds.width - textWidth) / 2.0,
                                 y: logoView.frame.maxY + 12,
                                 width: textWidth,
                                 height: textLabel.bounds.height)
    }
}

public extension MBProgressHUD {
    
    @discardableResult
    public class func showDimoHUDAdded(to view: UIView, title: String?, animated: Bool) -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.8)
        hud.bezelView.layer.cornerRadius = 12.0
        hud.contentColor = UIColor.white
        hud.margin = 0
        hud.mode = .customView
        let dimoHUD = DimoHUD()
        dimoHUD.textLabel.text = title
        hud.customView = dimoHUD
        return hud
    }
    
}
