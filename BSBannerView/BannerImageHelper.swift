//
//  BannerImageHelper.swift
//  BSBannerView
//
//  Created by ucredit-XiaoYang on 2016/10/10.
//  Copyright © 2016年 XiaoYang. All rights reserved.
//

import Foundation
import UIKit

let localImage = UIImage(named: "default_img")

let queue = DispatchQueue(label: "load_image", attributes: .concurrent, target: nil)
let imageCache = NSCache<AnyObject, AnyObject>()

func loadImageFrom(_ imagePath: Any, flag: Int = -1, completion: @escaping (_ image: UIImage?, _ flag: Int) -> Void) {
    var image: UIImage?
    
    if imagePath is UIImage {
        
        image = imagePath as? UIImage
        completion(image, flag)
        
    } else {
        
        guard !(imagePath as! String).isEmpty else {
            return
        }
        
        let imageUrl = imagePath
        
        if let imageData = imageCache.object(forKey: imageUrl as AnyObject) as? Data {
            image = UIImage(data: imageData)
            completion(image, flag)
            
        } else {
            completion(localImage, flag)
            
            queue.async {
                let url = URL(string: imageUrl as! String)
                
                guard let data = fectchData(url!) else {
                    return
                }
                
                imageCache.setObject(data as AnyObject, forKey: imageUrl as AnyObject)
                
                DispatchQueue.main.async {
                    completion(UIImage(data: data), flag)
                }
                
            }
        }
    }
    
}

func fectchData(_ url: URL) -> Data? {
    if let data = try? Data(contentsOf: url) { return data }
    return nil
}
