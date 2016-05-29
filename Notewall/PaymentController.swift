//
//  PaymentController.swift
//  Pin!t
//
//  Created by Bharath on 06/04/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

class PaymentController:UIViewController {
    
    var viewRect:CGRect?
    var pinView:PinBuy?
    var noteView:NoteBuy?
    var productNames:Dictionary<Int,Dictionary<String,AnyObject>> = [:]
    var activity:UIActivityIndicatorView?
    var pinBuyDelegate:PinBuyProtocolDelegate?
    var transactionInProgress = false
    var selectedProductIndex = -1
    var products:Dictionary<String,Int> = [:]
    var textColor:UIColor = UIColor.whiteColor()
    var module:String?
    
    init(frame:CGRect,overrideTextColor:UIColor?,module:String?) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewRect = frame
        self.module = module
        
        if (overrideTextColor != nil) {
            
            self.textColor = overrideTextColor!
        }
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        
         self.view = UIView(frame:self.viewRect!)
         self.view.backgroundColor = kOptionsBgColor
    }
    
    override func viewDidLoad() {
        
        if (self.module == "PIN") {
            
            if (self.pinView == nil) {
                
                self.pinView = PinBuy(frame: self.viewRect!, overrideTextColor: UIColor.blackColor())
                self.view.addSubview(self.pinView!)
            }
            
        }
        else if (self.module == "NOTE") {
            
            if (self.noteView == nil) {
                
                self.noteView = NoteBuy(frame: self.viewRect!)
                self.view.addSubview(self.noteView!)
            }
            
        }
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        if (self.pinView != nil) {
            
            self.pinView!.removeTransactionObserver()
            
            self.pinView!.removeFromSuperview()
            self.pinView = nil
            
        }
        
        
        
    }
}