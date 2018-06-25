//
//  TicketViewController.swift
//  JXScratchTicketView
//
//  Created by jiaxin on 2018/6/25.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

class TicketViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white

        let margin: CGFloat = 20
        let width = UIScreen.main.bounds.size.width - margin*2
        let height = width*(300/400)
        let scratchView = JXScratchTicketView(frame: CGRect(x: margin, y: 100, width: width, height: height))
        self.view.addSubview(scratchView)
    }
}
