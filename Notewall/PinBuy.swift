//
//  PinBuy.swift
//  Pin!t
//
//  Created by Bharath on 19/03/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

extension SKProduct {
    
    func localizedPrice() -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = self.priceLocale
        return formatter.stringFromNumber(self.price)!
    }
    
}

protocol PinBuyProtocolDelegate {
    
    func presentAlertController(action:UIAlertController)
    func pinPurchaseSuccessful(result:Bool,message:String?)
}


class PinBuy:UIView,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    //var productNames:Dictionary<Int,Dictionary<String,AnyObject>> = [:]
    var productNames:Array<Dictionary<String,AnyObject>> = []
    var activity:UIActivityIndicatorView?
    var pinBuyDelegate:PinBuyProtocolDelegate?
    var transactionInProgress = false
    var selectedProductIndex = -1
    var products:Dictionary<String,Int> = [:]
    var textColor:UIColor = UIColor.whiteColor()
    
    
    init(frame: CGRect, overrideTextColor:UIColor?) {
        
        super.init(frame:frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        if (overrideTextColor != nil) {
            
            textColor = overrideTextColor!
        }
        
        if (activity == nil) {
            
            let dim = Common.sharedCommon.calculateDimensionForDevice(30)
            
            activity = UIActivityIndicatorView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width * 0.5,dim * 0.5,dim,dim))
            self.addSubview(activity!)
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            
            self.activity!.startAnimating()
        })
        
        self.checkPinAvailability()
    }
    

    required init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeTransactionObserver() {
        
        SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
    }
    
    
    // SKPRODUCTDELEGATE DELEGATE METHODS
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        activity!.stopAnimating()
        
        if (response.products.count != 0) {
            
            var index = 0
            var dict:Dictionary<String,AnyObject> = [:]
            
            for product in response.products {
                
                dict["price"] = (product as SKProduct).localizedPrice()
                dict["title"] = (product as SKProduct).localizedTitle
                dict["product"] = product as SKProduct
                let identifier = (product as SKProduct).productIdentifier
                dict["pincount"] = self.products[identifier]
                dict["description"] = (product as SKProduct).localizedDescription
                
                //productNames[index] = dict
                productNames.append(dict)
                
                index = index + 1
            }
            
            print(productNames)
            
            self.showBuyView()
        }
        else {
            
            
        }
        
        if response.invalidProductIdentifiers.count != 0 {
            
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    // TRANSACTION OBSERVER
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.activity!.stopAnimating()
            
        })
        
        for transaction in transactions{
            
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchased:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                self.transactionInProgress = false
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.activity!.startAnimating()
                    
                })
                
                self.updatePinCount()
                
                
            case SKPaymentTransactionState.Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                self.transactionInProgress = false
                
                Common.sharedCommon.showMessageViewWithMessage(self, message: "Transaction failed/cancelled", startTimer: true)
                
            default:
                self.transactionInProgress = false
                print(transaction.transactionState.rawValue)
            }
        }
        
    }
    
    // CUSTOM METHODS
    
    func showBuyView() {
        
        let xPos = Common.sharedCommon.calculateDimensionForDevice(10)
        var yPos = Common.sharedCommon.calculateDimensionForDevice(40)
        let typeLabelWidth = UIScreen.mainScreen().bounds.size.width * 0.40
        let priceLabelWidth = typeLabelWidth
        let labelHeight = Common.sharedCommon.calculateDimensionForDevice(50)
        var index = 0
        
        
        //for key in productNames.keys {
        for idx in 0 ..< productNames.count {
            
           /* var getIndex = idx
            
            if (idx == 1){
                
                getIndex = 2
            }
            else if(idx == 2) {
                
                getIndex = 1
            }
            
            
            let typeText = productNames[getIndex]!["title"]! as! String
            let typePrice = productNames[getIndex]!["price"]! as! String
            let desc =  productNames[getIndex]!["description"]! as! String */
            
            let typeText = productNames[idx]["title"]! as! String
            let typePrice = productNames[idx]["price"]! as! String
            let desc =  productNames[idx]["description"]! as! String
            
            
            let typeLabel = UILabel(frame: CGRectMake(xPos,yPos,typeLabelWidth,labelHeight))
            typeLabel.textAlignment = NSTextAlignment.Left
            typeLabel.textColor = textColor
            typeLabel.font = UIFont(name: "Roboto", size: Common.sharedCommon.calculateDimensionForDevice(25))
            typeLabel.text = typeText
            self.addSubview(typeLabel)
            
            let priceLabel = UILabel(frame: CGRectMake(typeLabel.frame.origin.x + typeLabel.frame.size.width, typeLabel.frame.origin.y,priceLabelWidth,labelHeight ))
            priceLabel.textAlignment = NSTextAlignment.Center
            priceLabel.textColor = textColor
            priceLabel.font = UIFont(name: "Roboto", size: Common.sharedCommon.calculateDimensionForDevice(25))
            priceLabel.text = typePrice
            self.addSubview(priceLabel)
            
            
            let buttonWidth = UIScreen.mainScreen().bounds.size.width - (typeLabel.frame.size.width + priceLabel.frame.size.width)
            let buyButton = CustomButton(frame: CGRectMake(priceLabel.frame.origin.x + priceLabel.frame.size.width,priceLabel.frame.origin.y,buttonWidth,priceLabel.frame.size.height), buttonTitle: "BUY", normalColor: textColor, highlightColor: UIColor.blackColor())
            buyButton.tag = index
            buyButton.backgroundColor = UIColor.clearColor()
            buyButton.addTarget(self, action: #selector(PinBuy.buyButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            self.addSubview(buyButton)
            
            let description = UILabel(frame: CGRectMake(typeLabel.frame.origin.x, typeLabel.frame.origin.y + typeLabel.frame.size.height,priceLabelWidth * 2,labelHeight * 0.25))
            description.textAlignment = NSTextAlignment.Left
            description.textColor = textColor
            description.font = UIFont(name: "Roboto", size: Common.sharedCommon.calculateDimensionForDevice(12))
            description.text = desc
            self.addSubview(description)
            
            yPos = yPos + labelHeight + description.frame.size.height +  5
            index = index + 1
            
        }
        
    }
    
    
    
    func getProductIDs() {
        
        if SKPaymentQueue.canMakePayments() {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.activity!.startAnimating()
            })
            
            Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathGetPinPacks , body: nil, replace: nil, requestContentType: kContentTypes.kApplicationJson , completion: { (result, response) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.activity!.stopAnimating()
                })
                
                if (result == true) {
                    
                    self.products = response["data"] as! Dictionary
                    
                    let productIdentifiers = NSSet(array: Array(self.products.keys))
                    let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
                    
                    productRequest.delegate = self
                    productRequest.start()
                }
                else {
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.activity!.stopAnimating()
                        self.pinBuyDelegate!.pinPurchaseSuccessful(false,message:"Not able to connect to server")
                        
                    })
                    
                }
            })
            
        }
    }
    
    func buyButtonTapped(sender:CustomButton) {
        
        if self.transactionInProgress {
            
            return
        }
        
        
        if (self.pinBuyDelegate != nil) {
            
                SKPaymentQueue.defaultQueue().addTransactionObserver(self)
            
                self.selectedProductIndex = sender.tag
                let product = productNames[sender.tag]["product"] as! SKProduct
        
                let actionSheetController = UIAlertController(title: "PINS", message: "What do you want to do?", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
                let buyAction = UIAlertAction(title: "Buy", style: UIAlertActionStyle.Default) { (action) -> Void in
            
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                        self.activity!.startAnimating()
                
                    })
            
                    let payment = SKPayment(product: product)
                    SKPaymentQueue.defaultQueue().addPayment(payment)
                    self.transactionInProgress = true
                }
        
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
                        self.transactionInProgress = false
                }
        
                actionSheetController.addAction(buyAction)
                actionSheetController.addAction(cancelAction)
        
                self.pinBuyDelegate!.presentAlertController(actionSheetController)
        }
        else {
            
         /*   self.selectedProductIndex = sender.tag
            let product = productNames[sender.tag]!["product"] as! SKProduct
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.activity!.startAnimating()
                
            })
            
            let payment = SKPayment(product: product)
            SKPaymentQueue.defaultQueue().addPayment(payment)
            self.transactionInProgress = true */
        }
        
    }
    
    func updatePinCount() {
        
        if (self.selectedProductIndex >= 0) {
            
            let productType = productNames[ self.selectedProductIndex]["title"] as! String
            let pinCount = productNames[ self.selectedProductIndex]["pincount"] as! Int
            let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String,"type":productType,"count":pinCount]
            
            
            Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathUpdatePinCount , body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson , completion: { (result, response) -> Void in
                
                self.selectedProductIndex = -1
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.activity!.stopAnimating()
                    
                })
                
                if (result == true) {
                    
                    let errMsg = response.objectForKey("data")!.objectForKey("error")
                    
                    if (errMsg != nil ) {
                        
                        Common.sharedCommon.showMessageViewWithMessage(self, message: "Error in update.Please contact support", startTimer: true)
                        
                    }
                    else {
                        
                        Common.sharedCommon.showMessageViewWithMessage(self, message: "Pin Count updated", startTimer: true)
                        
                        if (self.pinBuyDelegate != nil) {
                            
                            self.pinBuyDelegate!.pinPurchaseSuccessful(true,message:nil)
                        }
                        
                        
                    }
                }
                else {
                    
                   Common.sharedCommon.showMessageViewWithMessage(self, message: "Error Connecting to Server.Contact Support", startTimer: true)
                    print(response)
                }
                
            })
            
        }
    }
    
    
    func checkPinAvailability() {
        
        let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathGetPins , body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.activity!.stopAnimating()
            })
            
            
            if (result == true) {
                
                let err:String? = response.objectForKey("data")?.objectForKey("error") as? String
                
                if (err == nil) {
                    
                    
                    let data = response.objectForKey("data") as? Dictionary<String,AnyObject>
                    Common.sharedCommon.showPins(data!, attachView: self, attachPosition: CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, Common.sharedCommon.calculateDimensionForDevice(30)),delegate:nil)
                    
                    self.getProductIDs()
                    
                }
                else {
                    
                    print(err)
                }
                
            }
            else {
                
                print(response["data"])
                
            }
        }
        
    }
    
}
