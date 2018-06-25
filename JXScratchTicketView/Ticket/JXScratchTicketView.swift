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
        bgImageView.contentMode = .scaleAspectFill
        addSubview(bgImageView)

        let contentView = UILabel()
        contentView.backgroundColor = UIColor.white
        contentView.font = UIFont.systemFont(ofSize: 25)
        contentView.text = "恭喜你获取豪华跑车兰博基尼，满100万减1万抵用券"
        contentView.numberOfLines = 0

        let maskView = UIView()
        maskView.backgroundColor = UIColor.lightGray

        scratchView = JXScratchView(contentView: contentView, maskView: maskView)
        scratchView.delegate = self
        scratchView.frame = CGRect(x: 33, y: 140, width: 337, height: 154)
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
