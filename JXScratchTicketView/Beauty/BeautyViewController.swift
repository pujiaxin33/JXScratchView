//
//  BeautyViewController.swift
//  JXScratchTicketView
//
//  Created by jiaxin on 2018/6/25.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

class BeautyViewController: UIViewController {
    var aboveImageView: UIImageView!
    var underImageView: UIImageView!
    var beautyView: JXScratchView!

    var currentIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        aboveImageView = UIImageView()
        underImageView = UIImageView()

        beautyView = JXScratchView(contentView: underImageView, maskView: aboveImageView)
        beautyView.strokeLineWidth = 30
        let margin: CGFloat = 20
        let width = UIScreen.main.bounds.size.width - margin*2
        let height = width*(480/320)
        beautyView.frame = CGRect(x: margin, y: 100, width: width, height: height)
        self.view.addSubview(beautyView)

        reloadData()

        let tap = UITapGestureRecognizer(target: self, action: #selector(nextBeauty))
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(tap)
    }

    @objc func nextBeauty() {
        currentIndex += 1
        reloadData()
    }

    func reloadData() {
        let index = currentIndex%9 + 1
        var aboveImageName = String(format: "g%d_up", index)
        var underImageName = String(format: "g%d_back", index)
        if index >= 8 {
            aboveImageName.append(".jpg")
            underImageName.append(".jpg")
        }
        aboveImageView.image = UIImage(named: aboveImageName)
        underImageView.image = UIImage(named: underImageName)
        beautyView.resetState()
    }

}
