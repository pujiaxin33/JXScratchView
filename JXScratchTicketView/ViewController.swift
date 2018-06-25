//
//  ViewController.swift
//  JXScratchTicketView
//
//  Created by jiaxin on 2018/6/25.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = TicketViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = BeautyViewController()
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}

