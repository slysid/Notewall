//
//  SettingsScroll.swift
//  Notewall
//
//  Created by Bharath on 24/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

class SettingsScroll:UIView {
    
    var titleLabel:UILabel?
    var scrollView:UIScrollView?
    var titleImage:UIImageView?
    
    init<T>(frame: CGRect, fillSettings:Array<T>, contentTypeTitle:String) {
        
        super.init(frame: frame)
        
        
        self.userInteractionEnabled = true
        self.backgroundColor = UIColor.clearColor()
        self.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin.union(.FlexibleRightMargin).union(.FlexibleTopMargin).union(.FlexibleBottomMargin)
        
        self.titleLabel = UILabel(frame: CGRectMake(0,0,self.frame.size.width,Common.sharedCommon.calculateDimensionForDevice(30)))
        self.titleLabel!.textAlignment = NSTextAlignment.Center
        self.titleLabel!.text = contentTypeTitle
        self.titleLabel!.backgroundColor = UIColor.grayColor()
        self.addSubview(self.titleLabel!)
        
        self.titleImage = UIImageView(frame:self.titleLabel!.frame)
        self.addSubview(self.titleImage!)
        
        self.scrollView = UIScrollView(frame: CGRectMake(0,self.titleLabel!.frame.size.height,self.frame.size.width,self.frame.size.height - self.titleLabel!.frame.size.height))
        self.scrollView!.contentSize = CGSizeMake((CGFloat(fillSettings.count) * self.scrollView!.frame.size.width), self.scrollView!.frame.size.height)
        self.scrollView!.backgroundColor = UIColor.clearColor()
        self.scrollView!.pagingEnabled = true
        self.scrollView!.showsHorizontalScrollIndicator = false
        self.addSubview(self.scrollView!)
        
        var xPos:CGFloat = 0.0
        let yPos:CGFloat = 0.0
        let width:CGFloat = self.scrollView!.frame.size.width
        let height:CGFloat = self.scrollView!.frame.size.height
        
        if (contentTypeTitle == "NOTES")
        {
            
            let image = UIImage(named:"notesL.png")
            self.titleImage!.image = image
            
            for index in 0 ..< fillSettings.count {
                
                let img = UIImageView(frame: CGRectMake(xPos, yPos, width, height))
                img.image = UIImage(named: fillSettings[index] as! String)
                self.scrollView!.addSubview(img)
                
                xPos = xPos + img.frame.size.width
            }
        }
        
        if (contentTypeTitle == "FONTS")
        {
            let image = UIImage(named:"fonts.png")
            self.titleImage!.image = image
            
            for index in 0 ..< fillSettings.count {
                
                let lbl = UILabel(frame: CGRectMake(xPos, yPos, width, height))
                let font = UIFont(name: fillSettings[index] as! String, size: 20.0)
                lbl.font = font
                lbl.text = "SAMPLE"
                lbl.backgroundColor = UIColor.whiteColor()
                lbl.textColor = UIColor.blackColor()
                lbl.textAlignment = NSTextAlignment.Center
                self.scrollView!.addSubview(lbl)
                
                xPos = xPos + lbl.frame.size.width
            }
            
            
        }
        
        if (contentTypeTitle == "SIZE") {
            
            let image = UIImage(named:"size.png")
            self.titleImage!.image = image
            
            for index in 0 ..< fillSettings.count {
                
                let lbl = UILabel(frame: CGRectMake(xPos, yPos, width, height))
                let font = UIFont(name: "Thonburi-Bold", size: 20.0)
                lbl.font = font
                lbl.text = String(fillSettings[index] as! CGFloat)
                lbl.backgroundColor = UIColor.whiteColor()
                lbl.textColor = UIColor.blackColor()
                lbl.textAlignment = NSTextAlignment.Center
                self.scrollView!.addSubview(lbl)
                
                xPos = xPos + lbl.frame.size.width
            }
            
        }
        
        if (contentTypeTitle == "COLORS") {
            
            let image = UIImage(named:"colors.png")
            self.titleImage!.image = image
            
            for index in 0 ..< kFontColor.count {
                
                let v = UIView(frame: CGRectMake(xPos, yPos, width, height))
                v.backgroundColor =   fillSettings[index] as? UIColor
                v.backgroundColor = Common.sharedCommon.formColorWithRGB(kFontColor[index])
                self.scrollView!.addSubview(v)
                
                xPos = xPos + v.frame.size.width
            }
            
        }
        
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
