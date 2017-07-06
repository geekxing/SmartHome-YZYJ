//
//  UIImage+Extension.swift
//  ProductTest
//
//  Created by 赖霄冰 on 2017/1/15.
//  Copyright © 2017年 helloworld.com. All rights reserved.
//

import UIKit

extension UIImage {
    
    func image(with borderWidth:CGFloat, borderColor:UIColor) -> UIImage {
        let ctxSize = CGSize(width: self.size.width + 2 * borderWidth, height: self.size.height + 2 * borderWidth)
        UIGraphicsBeginImageContextWithOptions(ctxSize, false, 0)
        var path = UIBezierPath(ovalIn: CGRect(origin: CGPoint.zero, size: ctxSize))
        borderColor.setFill()
        
        let drawRect = CGRect(x: borderWidth, y: borderWidth, width: self.size.width, height: self.size.height)
        path = UIBezierPath(ovalIn: drawRect)
        path.addClip()
        self.draw(in: drawRect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    //获取圆形图片
    func circleImage() -> UIImage? {
        return self.circleImage(to: self.size)
    }
    
    func circleImage(to size:CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let ctx = UIGraphicsGetCurrentContext()
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        ctx?.addEllipse(in: rect)
        ctx?.clip()
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    ///对指定图片进行拉伸
    func resizableImage(name: String) -> UIImage {
        
        var normal = UIImage(named: name)!
        let imageWidth = normal.size.width * 0.5
        let imageHeight = normal.size.height * 0.5
        normal = resizableImage(withCapInsets: (UIEdgeInsetsMake(imageHeight, imageWidth, imageHeight, imageWidth)))
        
        return normal
    }
    
    /**
     *  压缩上传图片到指定字节
     *
     *  image     压缩的图片
     *  maxLength 压缩后最大字节大小
     *
     *  return 压缩后图片的二进制
     */
    func compressImage(maxLength: Int) -> Data? {
        
        let newSize = self.imageSize(with: CGFloat(maxLength))
        let newImage = self.resizeImage(newSize: newSize) ?? self
        
        var compress:CGFloat = 0.9
        var data = UIImageJPEGRepresentation(newImage, compress)
        
        let maxSize = maxLength * 1024
        while data!.count > maxSize && compress > 0.01 {
            compress -= 0.1
            data = UIImageJPEGRepresentation(newImage, compress)
        }
        
        return data
    }
    
    /**
     *  通过指定图片最长边，获得等比例的图片size
     *
     *  image       原始图片
     *  imageLength 图片允许的最长宽度（高度）
     *
     *  return 获得等比例的size
     */
    func imageSize(with imageLength: CGFloat) -> CGSize {
        
        var newWidth:CGFloat = 0.0
        var newHeight:CGFloat = 0.0
        let width = self.size.width
        let height = self.size.height
        
        if (width > imageLength || height > imageLength){
            
            if (width > height) {
                
                newWidth = imageLength;
                newHeight = newWidth * height / width;
                
            }else if(height > width){
                
                newHeight = imageLength;
                newWidth = newHeight * width / height;
                
            }else{
                
                newWidth = imageLength;
                newHeight = imageLength;
            }
            
        }
        return CGSize(width: newWidth, height: newHeight)
    }
    
    /**
     *  获得指定size的图片
     *
     *  image   原始图片
     *  newSize 指定的size
     *
     *  return 调整后的图片
     */
    func resizeImage(newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /// 获取颜色填充而成的图片
    ///
    /// - Parameter color: 颜色
    /// - Returns: 图片
    class func imageWith(_ color:UIColor) -> UIImage? {
        let rect =  CGRect(x:0, y:0, width:1, height:1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setFillColor(color.cgColor)
        ctx?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
