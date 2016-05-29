//
//  FollowersController.swift
//  Pin!t
//
//  Created by Bharath on 08/04/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit


class FollowersController:UIViewController {
    
    var viewRect:CGRect?
    var optionsOptionView:OptionsOptionView?
    
    init(frame:CGRect) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewRect = frame
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        
        self.view = UIView(frame:self.viewRect!)
        
    }
    
    override func viewDidLoad() {
        
        self.view.backgroundColor = UIColor.redColor()
        
        if (self.optionsOptionView == nil) {
            
            self.optionsOptionView = OptionsOptionView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,UIScreen.mainScreen().bounds.size.height),fromSettings:true)
            self.optionsOptionView!.optionsOptionsDelegate = self.parentViewController as! NotewallController
            
            self.view.addSubview(optionsOptionView!)
            
        }
        
    }
    
    override func shouldAutorotate() -> Bool {
        
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        return UIInterfaceOrientationMask.Portrait
    }
}
