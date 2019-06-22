//
//  ViewController.swift
//  QRCodeReader
//
//  Created by 山本隆 on 2019/06/16.
//  Copyright © 2019 山本隆. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var cameraSwitch: UISwitch!
    @IBOutlet weak var cameraView: CameraView!
    @IBOutlet weak var codeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cameraView.onCapture( callback: { result in
            self.codeLabel.text = result
        })
    }
    
    override func viewDidLayoutSubviews() {
        selectCamera(cameraSwitch.isOn);
    }

    @IBAction func changeCamera(_ sender: UISwitch) {
        selectCamera(sender.isOn);
    }

    func selectCamera(_ isRearCamera: Bool) {
        cameraLabel.text = isRearCamera ?  "リアカメラ" : "フロントカメラ"
        cameraView.setUpCamera(isRearCamera)
    }

}

