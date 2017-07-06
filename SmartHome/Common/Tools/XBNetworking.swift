//
//  XBNetworking.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2016/11/25.
//  Copyright © 2016年 helloworld.com. All rights reserved.
//

import UIKit
import SwiftyJSON
import SVProgressHUD
import Alamofire

public typealias Parameters = [String: Any]

class XBNetworking: NSObject {
    
    static let share = XBNetworking()
    
    let manager = NetworkReachabilityManager(host: "www.apple.com")
    var session:SessionManager?
    
    override init() {
        super.init()
        session = CustomSessionManager()
        
        manager?.listener = { status in
            print("Network Status Changed: \(status)")
        }
        manager?.startListening()
    }
    
    
    
    // MARK:- GET
    func getWithPath(path: String,paras: Dictionary<String,Any>?,success: @escaping ((_ result: JSON) -> ()),failure: @escaping ((_ error: Error) -> ())) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        session!.request(path, method: .get, parameters: paras)
            .responseJSON { (response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                success(json)
            case .failure(let error):
                failure(error)
            }
        }
        
    }
    
    // MARK:- POST
    func postWithPath(path: String,paras: Dictionary<String,Any>?,success: @escaping ((_ result: JSON, _ msg:String) -> ()),failure: @escaping ((_ error: Error) -> ())) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        session!.request(path, method: .post, parameters: paras)
            .responseJSON { (response) in
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                switch response.result {
                case .success(let value):
                    SVProgressHUD.dismiss()
                    let json = JSON(value)
                    let message = localizeMsg(path, code: json[Code].intValue)
                    //LogInfo(message: json.stringValue)
                    print(json)
                    success(json, message)
                case .failure(let error):
                    failure(error)
                }
        }
        
    }
    
    //MARK: - Upload
    func upload(_ images:[UIImage], url:String, maxLength:CGFloat, params:Parameters, success : @escaping (_ response : JSON)->(), failture : @escaping (_ error : Error)->()) {
        
        let headers = ["content-type":"multipart/form-data"]
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        session!.upload(
            multipartFormData: { multipartFormData in
                
                //遍历字典
                for (key, value) in params {
                    multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                }
                
                for i in 0..<images.count {
                    let data = images[i].compressImage(maxLength: 200)!
                   // try! data.write(to: URL(fileURLWithPath: "/Users/laixiaobing/Desktop/211.png"))
                    multipartFormData.append(data, withName: "head", fileName: "image\(i)", mimeType: "image/jpeg")
                }
        },
            to: url,
            headers: headers,
            encodingCompletion: { encodingResult in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        if let value = response.result.value as? Parameters {
                            let json = JSON(value)
                            success(json)
                            debugPrint(json)
                        }
                    }
                case .failure(let encodingError):
                    debugPrint(encodingError)
                    failture(encodingError)
                }
        }
        )
        
    }
    
    func cancel() {
        
        if #available(iOS 9.0, *) {
            session!.session.getAllTasks { (tasks) in
                self.makeObjectsPerformCancel(tasks)
            }
        } else {
            session!.session.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
                self.makeObjectsPerformCancel(dataTasks)
                self.makeObjectsPerformCancel(uploadTasks)
                self.makeObjectsPerformCancel(downloadTasks)
            })
        }
        
    }
    
    func makeObjectsPerformCancel(_ array:[URLSessionTask]) {
        
        for task in array {
            task.cancel()
        }
    }
    
    //MARK: - Private
    
    private func CustomSessionManager() -> SessionManager {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 5.0
        
        return Alamofire.SessionManager(configuration: configuration)
        
    }


}
