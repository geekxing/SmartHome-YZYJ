//
//  XBQRCodeScanViewController.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/15.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

class XBQRCodeScanViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate,
UIAlertViewDelegate {
    
    var device:AVCaptureDevice!
    var input:AVCaptureDeviceInput!
    var output:AVCaptureMetadataOutput!
    var imageOutput: AVCaptureStillImageOutput!
    var session:AVCaptureSession!
    var preview:AVCaptureVideoPreviewLayer!
    
    var returnScan:((String) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        fromCamera()
        
        //        capture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func setupUI(){
        self.title = "QR Code"
        self.view.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        self.view.addSubview(centerView)
        self.view.addSubview(scanRectView)
        self.view.addSubview(upView)
        self.view.addSubview(leftView)
        self.view.addSubview(rightView)
        self.view.addSubview(bottomView)
        self.view.addSubview(kuangView)
        self.view.addSubview(textLabel1)
        self.view.addSubview(textLabel2)
        
        
        centerView.snp.makeConstraints { (make) in
            make.width.equalTo(200*UIRate)
            make.height.equalTo(200*UIRate)
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view)
        }
        
        scanRectView.snp.makeConstraints { (make) in
            make.width.height.equalTo(centerView)
            make.center.equalTo(centerView)
        }
        
        upView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view)
            make.height.equalTo(200*UIRate)
            make.bottom.equalTo(centerView.snp.top)
        }
        
        leftView.snp.makeConstraints { (make) in
            make.width.equalTo((SCREEN_WIDTH - 200*UIRate)/2.0)
            make.height.equalTo(centerView)
            make.left.equalTo(0)
            make.centerY.equalTo(centerView)
        }
        
        rightView.snp.makeConstraints { (make) in
            make.width.equalTo((SCREEN_WIDTH - 200*UIRate)/2.0)
            make.height.equalTo(centerView)
            make.right.equalTo(self.view)
            make.centerY.equalTo(centerView)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view)
            make.height.equalTo(SCREEN_HEIGHT - 380*UIRate)
            make.left.equalTo(0)
            make.top.equalTo(centerView.snp.bottom)
        }
        
        kuangView.snp.makeConstraints { (make) in
            make.width.equalTo(200*UIRate)
            make.height.equalTo(200*UIRate)
            make.center.equalTo(centerView)
        }
        
        textLabel1.snp.makeConstraints { (make) in
            make.top.equalTo(centerView.snp.bottom).offset(15*UIRate)
            make.centerX.equalTo(self.view)
        }
        
        textLabel2.snp.makeConstraints { (make) in
            make.top.equalTo(textLabel1.snp.bottom).offset(5*UIRate)
            make.centerX.equalTo(self.view)
        }
    }
    
    private lazy var centerView: UIView = {
        let mView = UIView()
        mView.backgroundColor = UIColor.clear
        return mView
    }()
    
    private lazy var upView: UIView = {
        let mView = UIView()
        mView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return mView
    }()
    
    private lazy var leftView: UIView = {
        let mView = UIView()
        mView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return mView
    }()
    
    private lazy var rightView: UIView = {
        let mView = UIView()
        mView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return mView
    }()
    
    private lazy var bottomView: UIView = {
        let mView = UIView()
        mView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return mView
    }()
    
    private lazy var kuangView: UIImageView = {
        let mView = UIImageView()
        mView.image = UIImage(named: "scan_rect_316x196")
        return mView
    }()
    
    //添加中间的探测区域绿框
    private lazy var scanRectView: UIView = {
        let mView = UIView()
        mView.layer.borderColor = UIColor.green.cgColor
        mView.layer.borderWidth = 1;
        return mView
    }()
    
    private lazy var textLabel1: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFontSize(15*UIRate)
        label.text = NSLocalizedString("Put the QR code in the scan area", comment: "")
        return label
    }()
    
    private lazy var textLabel2: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFontSize(15*UIRate)
        return label
    }()
    
    func fromCamera() {
        do{
            
            self.session = AVCaptureSession()
            
            self.device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            try! device.lockForConfiguration()
            device.focusMode = .continuousAutoFocus
            device.unlockForConfiguration()
            
            self.input = try AVCaptureDeviceInput(device: device)
            
            self.output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            if UIScreen.main.bounds.size.height<500 {
                self.session.sessionPreset = AVCaptureSessionPreset640x480
            }else{
                self.session.sessionPreset = AVCaptureSessionPresetHigh
            }
            self.session.addInput(self.input)
            self.session.addOutput(self.output)
            
            self.output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            let scanSize:CGSize = CGSize(width: 200*UIRate, height: 200*UIRate)
            
            var scanRect:CGRect = CGRect(x:(SCREEN_WIDTH-scanSize.width)/2,y:(self.view.height-scanSize.height)/2,width: scanSize.width, height:scanSize.height)
            //计算rectOfInterest 注意x,y交换位置
            scanRect = CGRect(x:scanRect.origin.y/SCREEN_HEIGHT,
                              y:scanRect.origin.x/SCREEN_WIDTH,
                              width:scanRect.size.height/SCREEN_HEIGHT,
                              height:scanRect.size.width/SCREEN_WIDTH)
            
            //设置可探测区域
            self.output.rectOfInterest = scanRect
            
            self.preview = AVCaptureVideoPreviewLayer(session:self.session)
            self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.preview.frame = UIScreen.main.bounds
            self.view.layer.insertSublayer(self.preview, at: 0)
            
            //开始捕获
            self.session.startRunning()
            
        }catch _ as NSError{
            //打印错误消息
            let errorAlert = UIAlertController(title: "提醒", message: "请在iPhone的\"设置-隐私-相机\"选项中,允许本程序访问您的相机", preferredStyle: UIAlertControllerStyle.alert)
            
            self.present(errorAlert, animated: true, completion: nil)
            errorAlert.addAction(UIAlertAction.init(title: "好的", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
        }
    }
    
    func capture(){
        
        var imageConnect = AVCaptureConnection()
        
        for connection in imageOutput.connections{
            
            for port in (connection as! AVCaptureConnection).inputPorts {
                
                if (port as! AVCaptureInputPort).mediaType == AVMediaTypeVideo {
                    imageConnect = (connection as? AVCaptureConnection)!
                    break
                }
            }
        }
        
        imageOutput.captureStillImageAsynchronously(from: imageConnect) { (buffer, error) in
            
        }
    }
    
    //摄像头捕获
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        var stringValue:String?
        
        print("扫描结果：\(metadataObjects)")
        
        if self.returnScan != nil {
            if let metadata = metadataObjects.first {
                let metaObj = metadata as! AVMetadataMachineReadableCodeObject
                self.returnScan!(metaObj.stringValue)
            }
        }
        
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            stringValue = metadataObject.stringValue
            
            if stringValue != nil{
                self.session.stopRunning()
            }
        }
        self.session.stopRunning()
        self.navigationController!.popViewController(animated: true)
    }
    
}
