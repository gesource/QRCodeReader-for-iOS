//
//  CameraView.swift
//  QRCodeReader
//
//  Created by 山本隆 on 2019/06/16.
//  Copyright © 2019 山本隆. All rights reserved.
//

import UIKit
import AVFoundation

class CameraView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    private var device: AVCaptureDevice!
    private var session: AVCaptureSession!
    private var output: AVCaptureMetadataOutput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var previewView: UIView!
    private var qrView: UIView!
    private var callback: ((String) -> Void)! = nil
    
    override func layoutSubviews() {
        super.layoutSubviews();
        self.initView()
    }
    
    private func initView() {
        for v in self.subviews {
            v.removeFromSuperview()
        }

        self.previewView = UIView()
        self.previewView.isOpaque = false
        self.addSubview(self.previewView)
        self.previewView.translatesAutoresizingMaskIntoConstraints = false
        self.previewView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        self.previewView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.previewView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        self.previewView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true

        self.qrView = UIView()
        self.qrView.layer.borderWidth = 2
        self.qrView.layer.borderColor = UIColor.red.cgColor
        self.qrView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        self.addSubview(self.qrView)
    }
    
    func setUpCamera(_ isRearCamera: Bool) {
        // セッションを生成
        session = AVCaptureSession()
        // カメラを選択
        let devicePosition: AVCaptureDevice.Position = isRearCamera ? .back : .front
        device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: devicePosition)
        // カメラからキャプチャ入力生成
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        session.addInput(input)
        output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        // プレビューレイヤを生成
        self.previewLayer = AVCaptureVideoPreviewLayer(session: session)
        self.previewLayer.frame = self.bounds
        self.previewView?.layer.sublayers?.removeAll()
        self.previewView?.layer.addSublayer(previewLayer)
        // セッションを開始
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            return;
        }
        // 複数のメタデータを検出できる
        for metadata in metadataObjects {
            // QRコードのデータかどうかの確認
            let data = metadata as! AVMetadataMachineReadableCodeObject
            if data.type == AVMetadataObject.ObjectType.qr {
                let barcode = previewLayer.transformedMetadataObject(for: data)
                let obj = barcode as! AVMetadataMachineReadableCodeObject
                self.qrView.frame = obj.bounds
                if data.stringValue != nil {
                    // 検出データを取得
                    self.callback(data.stringValue!)
                }
            }
        }
    }
    
    func onCapture(callback: @escaping (_ code: String) -> (Void)) {
        self.callback = callback
    }
}
