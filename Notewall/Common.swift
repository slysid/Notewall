//
//  Common.swift
//  Notewall
//
//  Created by Bharath on 22/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit


extension Int
{
    static func random(range: Range<Int> ) -> Int
    {
        var offset = 0
        
        if range.startIndex < 0   // allow negative ranges
        {
            offset = abs(range.startIndex)
        }
        
        let mini = UInt32(range.startIndex + offset)
        let maxi = UInt32(range.endIndex   + offset)
        
        return Int(mini + arc4random_uniform(maxi - mini)) - offset
    }
}


class Common:NSObject {
    
    static let sharedCommon = Common()
    var config:NSMutableDictionary?
    var timerCount:Int = 0
    var timer:NSTimer?
    var messageView:MessageView?
    
    override init() {
        
        
    }
    
    func calculateDimensionForDevice(val:CGFloat) -> CGFloat {
        
        if kDevice == kPhone {
            
            return val
        }
        else {
            
            return val * 2.0
        }
    }
    
    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint, preferredFont:String?, preferredFontSize:CGFloat?,preferredFontColor:UIColor?, addExpiry:Bool, expiryDate:String?)->UIImage{
        
        var font:String?
        var fontSize:CGFloat = kStickyNoteFontSize
        var fontColor:UIColor = kDefaultFontColor
        var msg:NSMutableAttributedString?
        
        if (preferredFont == nil) {
            
            font = kDefaultFont
        }
        else {
            
            font = preferredFont
        }
        
        if (preferredFontSize != nil) {
            
            fontSize = preferredFontSize!
        }
        
        if (preferredFontColor != nil) {
            
            fontColor = preferredFontColor!
        }
        
        let textFont: UIFont = UIFont(name: font!, size: fontSize)!
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: fontColor,
        ]
        
        if (addExpiry == false) {
            
            msg = NSMutableAttributedString(string: drawText as String, attributes: textFontAttributes)
        }
        else {
            
            let dateText = expiryDate! + " \n"
            let dateTextFont: UIFont = UIFont(name:"Arial",size:8.0)!
            let dateTextFontAttributes = [
                NSFontAttributeName: dateTextFont,
                NSForegroundColorAttributeName: fontColor,
            ]
            
            msg = NSMutableAttributedString(string: dateText, attributes: dateTextFontAttributes)
            let msg1 = NSMutableAttributedString(string: drawText as String, attributes: textFontAttributes)
            msg!.appendAttributedString(msg1)
        }
        
        
        //UIGraphicsBeginImageContext(inImage.size)
        UIGraphicsBeginImageContextWithOptions(inImage.size,false,0.0)
        let imgRect = CGRectMake(0,0,inImage.size.width,inImage.size.height)
        inImage.drawInRect(imgRect)
        //let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        let rect: CGRect = CGRectInset(imgRect, 38, 38)
        //drawText.drawInRect(rect, withAttributes: textFontAttributes)
        msg!.drawInRect(rect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
        
    }
    
    
    func ageOfApplication() -> NSTimeInterval {
        
        return NSDate().timeIntervalSinceDate(Common.sharedCommon.config!["loggedinDate"] as! NSDate)
    }
    
    func formPostURLRequest(path:String) -> NSMutableURLRequest {
        
        let postURL = NSURL(string:kHttpProtocol + "://" + kHttpHost + ":5000" + path)
        let postRequest = NSMutableURLRequest(URL: postURL!)
        return postRequest
    }
    
    func formPostBody(data:NSDictionary?) -> NSData? {
        
        do {
            
            let postBody =  try NSJSONSerialization.dataWithJSONObject(data!, options: NSJSONWritingOptions())
            
            return postBody
            
        } catch {
            
            return nil
        }
        
    }
    
    func formMultipartFormData(data:NSDictionary?,imageName:String) -> NSData? {
        
        let boundry = "helloWSXCDF"
        let httpBody:NSMutableData? = NSMutableData()
        
        var httpBodyStr = "\r\n--" + boundry + "\r\n" + "Content-Disposition:form-data; name=\"file\"; filename=\"" + imageName + "\"" + "\r\n" + "Content-Type:image/jpeg\r\n\r\n"
        httpBody!.appendData(NSString(string: httpBodyStr).dataUsingEncoding(NSUTF8StringEncoding)!)
        if (Common.sharedCommon.config![kKeyPolaroid] != nil) {
            
            httpBody!.appendData(Common.sharedCommon.config![kKeyPolaroid] as! NSData)
        }
        
        httpBodyStr = "\r\n--" + boundry + "\r\n" + "Content-Disposition:form-data; name=\"jsondata\"" + "\r\n" + "Content-Type:application/json" + "\r\n\r\n"
        httpBody!.appendData(NSString(string: httpBodyStr).dataUsingEncoding(NSUTF8StringEncoding)!)
        httpBody!.appendData(self.formPostBody(data)!)
        httpBody!.appendData(NSString(string: "\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
        httpBodyStr = "\r\n--" + boundry + "--\r\n"
        httpBody!.appendData(NSString(string: httpBodyStr).dataUsingEncoding(NSUTF8StringEncoding)!)
        
        return httpBody
        
    }
    
    
    func postRequestAndHadleResponse(path :kAllowedPaths, body:NSDictionary?, replace:NSDictionary?, requestContentType:kContentTypes, completion : (Bool,NSDictionary) -> Void) {
        
        
        if kRunMode == kRunModes.modeDebug {
            
            switch path {
                
            case .kPathHealth:
                completion(true,kDebugHealthResponse)
            case .kPathGetAllNotes:
                completion(true,kDebugAllNotesResponse)
            default: break
                
                
            }
        }
        else {
            
            let pathAttributes = kHttpPaths[path.hashValue]
            let method = pathAttributes["method"]
            var endpoint = pathAttributes["path"]
            
            if (replace != nil) {
                
                let keys = NSArray(array:replace!.allKeys)
                
                for key in keys {
                    
                    endpoint = endpoint!.stringByReplacingOccurrencesOfString(key as! String, withString: replace!.objectForKey(key) as! String, options: NSStringCompareOptions.LiteralSearch, range: nil)
                }
            }
            
            let restRequest = formPostURLRequest(endpoint!)
            restRequest.HTTPMethod = method!
            
            
            if ((method == "POST" || method == "PUT" || method == "DELETE") && body != nil) {
                
                if (requestContentType == .kApplicationJson) {
                    
                    let postBody = formPostBody(body)
                    
                    if (postBody == nil) {
                        
                        print("Error in serializing post body")
                    }
                    else {
                        
                        restRequest.HTTPBody = postBody!
                        restRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    }
                }
                else if (requestContentType == .kMultipartFormData) {
                    
                    
                    let postBody = formMultipartFormData(body, imageName: body!["imageurl"] as! String)
                    
                    if (postBody == nil) {
                        
                        print("Error in serializing post body")
                    }
                    else {
                        
                        restRequest.HTTPBody = postBody!
                        restRequest.setValue("multipart/form-data; boundary=\"helloWSXCDF\"", forHTTPHeaderField: "Content-Type")
                        //restRequest.setValue("base64", forHTTPHeaderField: "Content-Transfer-Encoding")
                    }
                    
                }
                
            }
            
            
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            config.timeoutIntervalForRequest = 5.0
            let session = NSURLSession(configuration: config)
            let task = session.dataTaskWithRequest(restRequest) { (data, response, error) -> Void in
                
                
                if (error != nil) {
                    
                    let responseDict = NSDictionary(objects: [error!.description], forKeys: ["error"])
                    completion(false,responseDict)
                }
                else {
                    
                    let responseContentType = (response as! NSHTTPURLResponse).allHeaderFields["Content-Type"]! as! String
                    if (responseContentType.rangeOfString("image") != nil) {
                        
                        let responseDict = NSDictionary(objects: [data!], forKeys: ["image"])
                        completion(true,responseDict)
                    }
                    else {
                        
                        do {
                            
                            let jsonResponse = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
                            completion(true,jsonResponse as! NSDictionary)
                            
                        }
                        catch let err as NSError{
                            
                            let responseDict = NSDictionary(objects: [err.userInfo], forKeys: ["error"])
                            completion(false,responseDict)
                            
                        }
                        
                    }
                    
                }
            }
            
            task.resume()
            
        }
        
        
    }
    
    
    
    func formColorWithRGB(RGB:Array<CGFloat>) -> UIColor {
        
        return UIColor(red: RGB[0], green: RGB[1], blue: RGB[2], alpha: 1.0)
    }
    
    
    
    func showMessageViewWithMessage(controller:UIView,message:String,startTimer:Bool) {
        
        if (true) {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (startTimer == true) {
                    
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: Common.sharedCommon, selector: "updateTimer", userInfo: nil, repeats: true)
                }
                
                
                self.messageView = MessageView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,Common.sharedCommon.calculateDimensionForDevice(150)))
                self.messageView!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin .union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin).union(.FlexibleWidth)
                self.messageView!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, UIScreen.mainScreen().bounds.size.height * 0.75)
                self.messageView!.text = message
                controller.addSubview(self.messageView!)
                
            })
            
        }
        
    }
    
    func updateTimer() {
        
        self.timerCount = self.timerCount + 1
        
        if (self.timerCount >= 5) {
            
            self.timer!.invalidate()
            self.timerCount = 0
            self.messageView!.removeFromSuperview()
            self.timer = nil
        }
    }
    
}
