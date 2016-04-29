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


extension UIImage
{
    func noteImage(named noteType:String) -> UIImage?
    {
        print(noteType)
        let imageData = Common.sharedCommon.noteImageNameDataMap[noteType]
        if imageData == nil
        {
            return UIImage(named: noteType)
        }
        else
        {
            return UIImage(data: imageData!)
        }
        
    }
}


extension UIImage
{
    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage;
    }
}


class Common:NSObject {
    
    static let sharedCommon = Common()
    var config:NSMutableDictionary?
    var timerCount:Int = 0
    var timer:NSTimer?
    var messageView:MessageView?
    var noteImageNameDataMap:Dictionary<String,NSData> = [:]
    
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
        
        let postURL = NSURL(string:kHttpProtocol + "://" + kHttpHost + ":" + kHttpPort + path)
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
            
            if (path != kAllowedPaths.kPathNil) {
                
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
                    
                    if (Common.sharedCommon.config!["token"] != nil) {
                        
                        let token = Common.sharedCommon.config!["token"] as! String + ":unused"
                        //let token = "test:test"
                        restRequest.setValue(token, forHTTPHeaderField: "Authorization")
                    }
                    
                    
                    
                }
                
                
                let config = NSURLSessionConfiguration.defaultSessionConfiguration()
                config.timeoutIntervalForRequest = 15.0
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
        
        
    }
    
    
    
    func formColorWithRGB(RGB:Array<CGFloat>) -> UIColor {
        
        return UIColor(red: RGB[0], green: RGB[1], blue: RGB[2], alpha: 1.0)
    }
    
    
    
    func showMessageViewWithMessage(controller:UIView,message:String,startTimer:Bool) {
        
        if (true && self.timer == nil) {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if (startTimer == true) {
                    
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: Common.sharedCommon, selector: #selector(Common.updateTimer), userInfo: nil, repeats: true)
                }
                
                
                self.messageView = MessageView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,Common.sharedCommon.calculateDimensionForDevice(150)))
                self.messageView!.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin .union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin).union(.FlexibleWidth)
                self.messageView!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, UIScreen.mainScreen().bounds.size.height * 0.75)
                self.messageView!.text = message
                controller.addSubview(self.messageView!)
                
            })
            
        }
        else {
            
            self.timer?.invalidate()
            self.timerCount = 0
            self.timer = nil
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.messageView!.removeFromSuperview()
            })
            
            self.showMessageViewWithMessage(controller, message: message, startTimer: startTimer)
        }
        
    }
    
    func updateTimer() {
        
        self.timerCount = self.timerCount + 1
        
        if (self.timerCount >= 5) {
            
            self.invalidateTimerAndRemoveMessage()
        }
    }
    
    func invalidateTimerAndRemoveMessage() {
        
        dispatch_async(dispatch_get_main_queue(),{() -> Void in
            
            if (self.timer != nil) {
                
                self.timer!.invalidate()
            }
            self.timerCount = 0
            
            if (self.messageView != nil) {
                
                self.messageView!.removeFromSuperview()
            }
            
            self.timer = nil
        })
        
        
    }
    
    func getACoordinate(screenwidth:CGFloat,screenheight:CGFloat) -> CGPoint {
        
        let xOffset = CGFloat(Int.random(-60 ... 60))
        let yOffset = CGFloat(Int.random(-80 ... 80))
        
        let xPoint = (screenwidth * 0.50) +  xOffset
        var yPoint = (screenheight * 0.50) + yOffset
        
        if yPoint < 40 {
            
            yPoint = 40
        }
        
        return CGPointMake(xPoint,yPoint)
        
    }
    
    
    func showPins(data:Dictionary<String,AnyObject>, attachView:UIView, attachPosition:CGPoint?, delegate:PinButtonProtocolDelegate?) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            var pinPostView:UIView?
            
            if (pinPostView == nil) {
                
                let width = Common.sharedCommon.calculateDimensionForDevice(70)
                let height = Common.sharedCommon.calculateDimensionForDevice(30)
                
                pinPostView = UIView(frame: CGRectMake(0,0,width * CGFloat(data.count) ,height))
                if (attachPosition != nil) {
                    
                    pinPostView!.center = attachPosition!
                }
                else {
                    
                    pinPostView!.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, Common.sharedCommon.calculateDimensionForDevice(100))
                }
                
                pinPostView!.backgroundColor = UIColor.clearColor()
                attachView.addSubview(pinPostView!)
                
                var percent:CGFloat = 0.25
                var xPos:CGFloat = pinPostView!.frame.size.width * percent
                let yPos:CGFloat = height * 0.5
                
                var keys = Array(data.keys)
                
                for idx in 0 ..< keys.count {
                    
                    let type = keys[idx] as String
                    let count = String(data[type]!)
                    
                    
                    let pinType = PinButton(frame:CGRectMake(0,0,height,height),type:type,PinCount:count)
                    
                    if (delegate != nil) {
                        
                        pinType.pinButtonDelegate = delegate
                    }
                    
                    pinType.center = CGPointMake(xPos,yPos)
                    pinPostView!.addSubview(pinType)
                    
                    percent = percent + 0.25
                    xPos = pinPostView!.frame.size.width * percent
                }
            }
            
        }
        
    }
    
    
    func loadNotesImagesFromDocuments() {
        
        let documentsURL = NSFileManager.defaultManager().URLsForDirectory(NSSearchPathDirectory.DocumentDirectory , inDomains: NSSearchPathDomainMask.AllDomainsMask).first
        
        do {
            
            let directoryContents = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentsURL!, includingPropertiesForKeys: nil, options: NSDirectoryEnumerationOptions())
            
            if (directoryContents.count == 1) {
                
                self.getNotesImagesFromServer()
            }
            else {
                
                if let dir:NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                    
                    
                    var path = dir.stringByAppendingPathComponent("FreeNotesOrder.plist")
                    var pinNotes:NSArray = NSArray(contentsOfFile: path)!
                    kFreePinNotes = (pinNotes as? Array<Array<String>>)!
                    
                    for notesList in kFreePinNotes {
                        
                        for noteName in notesList {
                            
                            for content in directoryContents {
                                
                                let fileName = content.absoluteString.characters.split{$0 == "/"}.map(String.init).last
                                
                                if (fileName == noteName) {
                                    self.noteImageNameDataMap[fileName!] = NSData(contentsOfURL: content)
                                    break
                                }
                                
                            }
                        }
                    }
                    
                    kPinNotes = kFreePinNotes
                    
                    path = dir.stringByAppendingPathComponent("SponsoredNotesOrder.plist")
                    pinNotes = NSArray(contentsOfFile: path)!
                    kSponsoredPinNotes = (pinNotes as? Array<Array<String>>)!
                    
                    for notesList in kSponsoredPinNotes {
                        
                        for noteName in notesList {
                            
                            for content in directoryContents {
                                
                                let fileName = content.absoluteString.characters.split{$0 == "/"}.map(String.init).last
                                
                                if (fileName == noteName) {
                                    self.noteImageNameDataMap[fileName!] = NSData(contentsOfURL: content)
                                    break
                                }
                                
                            }
                        }
                    }
                    
                }
                
            }
        }
        catch {
            
        }
        
    }
    
    func getNotesImagesFromServer() {
        
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathNotesImages, body: nil, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) in
            
            if (result == true) {
                
                var data = response["data"]!["notes"]!!["free"] as! NSArray
                
                for notesList in data {
                    
                    var names:Array<String> = []
                    
                    for note in notesList as! NSArray {
                        
                        let fullURL = note as? String
                        let fileName = fullURL?.characters.split{$0 == "/"}.map(String.init).last
                        self.downloadImages(note as? String,fileName: fileName)
                        names.append(fileName!)
                    }
                    
                    kFreePinNotes.append(names)
                    
                }
                
                data = response["data"]!["notes"]!!["sponsored"] as! NSArray
                
                for notesList in data {
                    
                    var names:Array<String> = []
                    
                    for note in notesList as! NSArray {
                        
                        let fullURL = note as? String
                        let fileName = fullURL?.characters.split{$0 == "/"}.map(String.init).last
                        self.downloadImages(note as? String,fileName: fileName)
                        names.append(fileName!)
                    }
                    
                    kSponsoredPinNotes.append(names)
                }
                
                
                if let dir:NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                    
                    let path = dir.stringByAppendingPathComponent("FreeNotesOrder.plist")
                    let pinNotes:NSArray = kFreePinNotes
                    pinNotes.writeToFile(path, atomically: false)
                    
                }
                
                
                if let dir:NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                    
                    let path = dir.stringByAppendingPathComponent("SponsoredNotesOrder.plist")
                    let pinNotes:NSArray = kSponsoredPinNotes
                    pinNotes.writeToFile(path, atomically: false)
                    
                }
                
                kPinNotes = kFreePinNotes
                
            }
            else {
                
                print("Error in getting note types")
            }
        }
    }
    
    
    func downloadImages(imageURL:String?,fileName:String?) {
        
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: nil)
        let getURL = NSURL(string: imageURL!)
        let getNSURLRequest = NSURLRequest(URL: getURL!)
        let downloadTask = session.downloadTaskWithRequest(getNSURLRequest) { (location, response, error) in
            
           let imageData = NSData(contentsOfURL: location!)
           self.noteImageNameDataMap[fileName!] = imageData
           if let dir:NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                
                let path = dir.stringByAppendingPathComponent(fileName!)
                imageData?.writeToFile(path, atomically: false)
            
            }
        }
        
        downloadTask.resume()
        
    }
    
}
