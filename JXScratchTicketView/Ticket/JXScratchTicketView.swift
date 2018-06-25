//
//  JXScratchTicketView.swift
//  JXScratchTicketView
//
//  Created by jiaxin on 2018/6/25.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

class JXScratchTicketView: UIView {
    var scratchView: JXScratchView!

    override init(frame: CGRect) {
        super.init(frame: frame)

        let bgImageView = UIImageView(image: UIImage(named: "guaguale.jpg"))
        bgImageView.frame = self.bounds
        bgImageView.contentMode = .scaleAspectFill
        addSubview(bgImageView)

        let contentView = UILabel()
        contentView.backgroundColor = UIColor.white
        contentView.textAlignment = .center
        contentView.font = UIFont.systemFont(ofSize: 25)
        contentView.text = "恭喜你刮中500万"
        contentView.numberOfLines = 0

        let maskView = UIView()
        maskView.backgroundColor = UIColor.lightGray

        let ratio = self.bounds.size.width/400
        scratchView = JXScratchView(contentView: contentView, maskView: maskView)
        scratchView.delegate = self
        scratchView.strokeLineWidth = 25
        scratchView.strokeLineCap = kCALineCapRound
        scratchView.frame = CGRect(x: 33*ratio, y: 140*ratio, width: 337*ratio, height: 154*ratio)
        addSubview(scratchView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension JXScratchTicketView: JXScratchViewDelegate {
    func scratchView(scratchView: JXScratchView, didScratched percent: Float) {
        if percent >= 0.7 {
            scratchView.showContentView()
        }
    }
}
