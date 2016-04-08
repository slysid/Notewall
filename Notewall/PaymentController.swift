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
    var productNames:Dictionary<Int,Dictionary<String,AnyObject>> = [:]
    var activity:UIActivityIndicatorView?
    var pinBuyDelegate:PinBuyProtocolDelegate?
    var transactionInProgress = false
    var selectedProductIndex = -1
    var products:Dictionary<String,Int> = [:]
    var textColor:UIColor = UIColor.whiteColor()
    
    init(frame:CGRect,overrideTextColor:UIColor?) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewRect = frame
        
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
        
        if (self.pinView == nil) {
            
            self.pinView = PinBuy(frame: self.viewRect!, overrideTextColor: UIColor.blackColor())
            self.view.addSubview(self.pinView!)
        }
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        self.pinView!.removeTransactionObserver()
        
        self.pinView!.removeFromSuperview()
        self.pinView = nil
        
    }
}