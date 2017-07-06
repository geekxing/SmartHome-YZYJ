//
//  XBPhotoPickerManager.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/15.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import MobileCoreServices
import LGAlertView
import SVProgressHUD

public protocol XBPhotoPickerManagerDelegate:NSObjectProtocol {
    func imagePickerDidFinishPickImage(image:UIImage)
}

class XBPhotoPickerManager: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LGAlertViewDelegate {

    static let shared = XBPhotoPickerManager()
    
    var sourceType:UIImagePickerControllerSourceType = .photoLibrary
    var chooser:UIViewController?
    weak var delegate:XBPhotoPickerManagerDelegate?
    
    func pickIn(vc:UIViewController) {
        chooser = vc
        let alert = LGAlertView(title: NSLocalizedString("Choose a way to select your avatar", comment: ""), message: nil, style: .actionSheet, buttonTitles: [NSLocalizedString("PhotoLibrary", comment: ""),NSLocalizedString("Camera", comment: "")], cancelButtonTitle: NSLocalizedString("Cancel", comment: ""), destructiveButtonTitle: nil, delegate: self)
        alert.showAnimated()
    }
    
    //MARK: - Auths
    
    func checkCameraAuth(_ request:@escaping (Bool)->()) {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if(authStatus == .denied || authStatus == .restricted) {
            UIAlertView(title: NSLocalizedString("This app has no permission to camera" , comment: ""), message: NSLocalizedString("Please open the permission in Privacy Settings, otherwise the function cannot be used.", comment: ""), delegate: nil, cancelButtonTitle: NSLocalizedString("DONE", comment: "")).show()
            return
        }else {
            if authStatus == .authorized {
                request(true)
            } else {
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (grand) in
                    if grand {
                        DispatchQueue.main.async(execute: {
                            request(grand)
                        })
                    }
                })
            }
        }
    }
    
    //MARK: - Camera Access
    
    func hasAccessTo(_ sourceType:UIImagePickerControllerSourceType) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            return true
        } else {
            let alert = LGAlertView(title: NSLocalizedString("your device have no access to camera", comment: ""), message: nil, style: .alert, buttonTitles: [NSLocalizedString("DONE", comment: "")], cancelButtonTitle: nil, destructiveButtonTitle: nil)
            alert.showAnimated()
            return false
        }
    }
    
    //MARK: - Private
    private func open() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = [kUTTypeImage as String]
        chooser?.present(imagePicker, animated: true, completion: nil)
    }
    
    private func photoLibraryAuth() -> Bool {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        return authStatus != .denied && authStatus != .restricted
    }
    
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as? String
        if mediaType == kUTTypeImage as String {
            delegate?.imagePickerDidFinishPickImage(image: info[UIImagePickerControllerEditedImage] as! UIImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - LGAlertViewDelegate
    func alertView(_ alertView: LGAlertView, clickedButtonAt index: UInt, title: String?) {
        if index == 0  {
            self.sourceType = .photoLibrary
            guard self.hasAccessTo(.photoLibrary) else { return }
            self.open()
        } else {
            self.sourceType = .camera
            guard self.hasAccessTo(.camera) else {return }
            checkCameraAuth({ (grand) in
                if grand {
                    self.open()
                }
            })
        }
    }
}
