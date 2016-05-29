//
//  OptionsOptionView.swift
//  Pinwall
//
//  Created by Bharath on 27/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol OptionsOptionViewProtocolDelegate {
    
    func followingUpdated(followingID:String)
    func showNotesForSelectedFollowingOwnerInWall(dataList:NSArray)
}

class OptionsOptionView:UIView,UITableViewDataSource,UITableViewDelegate {
    
    var followersTable:UITableView?
    var menusTable:UITableView?
    let tableSectionHeight:CGFloat = 40
    var sectionIndexSet:NSMutableIndexSet?
    var rowsInFollowingSection = 0
    var rowsInFollowersSection = 0
    var followingDict:Dictionary<String,String> = [:]
    var following:Array<String> = []
    var followedDict:Dictionary<String,String> = [:]
    var followed:Array<String> = []
    var optionsOptionsDelegate:OptionsOptionViewProtocolDelegate?
    var fromSettings:Bool = false
    var pinPostView:UIView?
    
    init(frame: CGRect,fromSettings:Bool) {
        
        super.init(frame:frame)
        
        self.backgroundColor = kOptionsBgColor
        self.fromSettings = fromSettings
        
        self.showFollowersTable()
        
        /*if (fromSettings == true) {
            
            self.showAvailableOptions()
        }
        else {
            
            self.showFollowersTable()
        } */
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TABLEVIEW DELEGATE METHODS
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (tableView == self.followersTable) {
            
            if (section == 0) {
                
                return rowsInFollowersSection
            }
            else if (section == 1) {
                
                print(rowsInFollowingSection)
                return rowsInFollowingSection
            }
            else {
                
                return 0
            }
            
        }
        else {
            
            return kAvailableOptionsMenu.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if (tableView == self.followersTable) {
            
            var cell = tableView.dequeueReusableCellWithIdentifier("cell")
            
            if (cell == nil) {
                
                var textSize:CGFloat = Common.sharedCommon.calculateDimensionForDevice(20.0)
                
                if self.fromSettings == false {
                    
                    textSize = Common.sharedCommon.calculateDimensionForDevice(17.0)
                    
                }
                
                cell = UITableViewCell(style: UITableViewCellStyle.Default , reuseIdentifier: "cell")
                cell?.textLabel!.backgroundColor = self.backgroundColor
                cell?.contentView.backgroundColor = self.backgroundColor
                cell?.textLabel!.textColor = UIColor.blackColor()
                cell?.textLabel!.font = UIFont(name: "Roboto", size: textSize)
                
                let bgView = UIView()
                bgView.backgroundColor = self.backgroundColor
                bgView.userInteractionEnabled = true
                cell?.selectedBackgroundView = bgView
                
                if (tableView == self.followersTable) {
                    
                    let showButton = CustomButton(frame: CGRectMake(0,0,Common.sharedCommon.calculateDimensionForDevice(70) ,cell!.contentView.frame.size.height), buttonTitle: "Show", normalColor: UIColor.redColor(), highlightColor: nil)
                    showButton.backgroundColor = UIColor.clearColor()
                    showButton.userInteractionEnabled = true
                    showButton.center = CGPointMake(cell!.contentView.frame.size.width - (showButton.frame.size.width * 0.75), cell!.contentView.frame.size.height * 0.5)
                    showButton.indexPath = indexPath
                    //showButton.setTitle("Show", forState: UIControlState.Normal)
                    //showButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    showButton.addTarget(self, action: #selector(OptionsOptionView.showButtonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                    showButton.hidden = true
                    cell!.contentView.addSubview(showButton)
                }
                
            }
            
            
            if (indexPath.section == 0) {
                
                cell?.textLabel!.text = self.followed[indexPath.row]
            }
            else if (indexPath.section == 1) {
                
                cell?.textLabel!.text = self.following[indexPath.row]
            }
            
            return cell!
            
        }
        else {
            
            let cellText = kAvailableOptionsMenu[indexPath.row]["label"]! as String
            let cellImage = kAvailableOptionsMenu[indexPath.row]["image"]! as String
            
            var cell = tableView.dequeueReusableCellWithIdentifier("cell")
            
            if (cell == nil) {
                
                cell = MenuCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell", labelString:cellText, imageName:cellImage)
                cell?.textLabel!.backgroundColor = self.backgroundColor
                cell?.contentView.backgroundColor = self.backgroundColor
                cell?.textLabel!.textColor = UIColor.blackColor()
                cell?.textLabel!.font = UIFont(name: "Roboto", size: 20.0)
                
                let bgView = UIView()
                bgView.backgroundColor = self.backgroundColor
                bgView.userInteractionEnabled = true
                cell?.selectedBackgroundView = bgView
                
            }
            
            return cell!
            
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if (tableView == self.followersTable) {
            
            return 2
        }
        else {
            
            return 1
        }
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if (tableView == self.followersTable) {
            
            var textSize:CGFloat = Common.sharedCommon.calculateDimensionForDevice(24.0)
            
            if self.fromSettings == false {
                
                textSize = Common.sharedCommon.calculateDimensionForDevice(20.0)
                
            }
            
            let sectionLabel = UILabel(frame: CGRectMake(0,0,self.followersTable!.frame.size.width,tableSectionHeight))
            sectionLabel.textAlignment = NSTextAlignment.Center
            sectionLabel.textColor = UIColor.blackColor()
            sectionLabel.font = UIFont(name: "Roboto", size: textSize)
            sectionLabel.tag = section
            sectionLabel.userInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(OptionsOptionView.sectionTapped(_:)))
            sectionLabel.addGestureRecognizer(tap)
            
            
            if (tableView == self.followersTable) {
                
                if (section == 0) {
                    
                    sectionLabel.text = "Followers-(" + String(self.followed.count) + ")"
                }
                else if (section == 1) {
                    
                    sectionLabel.text = "Following-(" + String(self.following.count) + ")"
                }
                
            }
            else {
                
                sectionLabel.text = ""
            }
            
            
            return sectionLabel
            
        }
        else {
            
            return UILabel(frame: CGRectMake(0,0,0,0))
        }
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (tableView == self.followersTable) {
            
            return tableSectionHeight
        }
        else {
            
            return 0
        }
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        if (tableView == self.followersTable) {
            
            return Common.sharedCommon.calculateDimensionForDevice(40)
        }
        else {
            
            return Common.sharedCommon.calculateDimensionForDevice(60)
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if (tableView == self.followersTable) {
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            
            for b in cell!.contentView.subviews {
                
                if b is UIButton {
                    
                    (b as? UIButton)!.hidden = false
                }
            }
        }
        else {
            
            if (indexPath.row == 0) {
                
                
                self.showFollowersTable()
                
            }
            else {
                
                self.menusTable!.removeFromSuperview()
                self.menusTable = nil
                
                //self.checkPinAvailability()
                //self.showPinBuyView()
                
            }
        }
        
    }
    
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
         if (tableView == self.followersTable) {
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            
            for b in cell!.contentView.subviews {
                
                if b is UIButton {
                    
                    (b as? UIButton)!.hidden = true
                }
            }
        }
        
    }
    
    
   /* func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        if (tableView == self.followersTable) {
            
            if (self.fromSettings == true) {
                
                if (indexPath.section == 1) {
                    
                    return UITableViewCellEditingStyle.Delete
                }
                
                return UITableViewCellEditingStyle.Delete
            }
            else {
                
                return UITableViewCellEditingStyle.None
            }
        }
        else {
            
            
            return UITableViewCellEditingStyle.None
        }
    
    } */
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let blockAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Block") { (UITableViewRowAction, NSIndexPath) in
            
            print("block")
        }
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { (UITableViewRowAction, NSIndexPath) in
            
              self.commitDeleteActionFor(tableView, indexPath: indexPath)
        }
        
        if (tableView == self.followersTable)
        {
            
            if (self.fromSettings == true)
            {
                
                if (indexPath.section == 0)
                {
                    
                    return [blockAction]
                }
                
                return [deleteAction]
            }
            else
            {
                
                return []
            }
        
        }
        
        return []
        
    }
    
    func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        
        if (tableView == self.followersTable) {
            
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            
            for b in cell!.contentView.subviews {
                
                if b is UIButton {
                    
                    (b as? UIButton)!.hidden = true
                }
            }
            
        }

    }
    

    
    /* func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) { */
    
    func commitDeleteActionFor(tableView:UITableView,indexPath: NSIndexPath)
    {
        
        if (tableView == self.followersTable)
        {
                
                let section = indexPath.section
                let row = indexPath.row
                let ownerName = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text
                var selectedOwner:String?
                
                if (section == 0)
                {
                    
                    self.followed.removeAtIndex(row)
                    selectedOwner = self.followedDict[ownerName!]
                }
                else if (section == 1)
                {
                    
                    self.following.removeAtIndex(row)
                    selectedOwner = self.followingDict[ownerName!]
                }
                
                rowsInFollowersSection = self.followed.count
                rowsInFollowingSection = self.following.count
            
                
                let ownerID = Common.sharedCommon.config!["ownerId"] as! String
                let paramData = NSDictionary(objects: [selectedOwner!], forKeys: ["<followownerid>"])
                let data = ["ownerid" : ownerID]
                
                Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathFollow, body: data, replace: paramData, requestContentType: kContentTypes.kApplicationJson, completion: { (result, response) -> Void in
                    
                    if (result == true)
                    {
                        
                        if (response["error"] == nil)
                        {
                            
                            dispatch_async(dispatch_get_main_queue() , { () -> Void in
                                
                                //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                                
                                self.sectionTapped(nil)
                                
                                if (self.optionsOptionsDelegate != nil)
                                {
                                    
                                    self.optionsOptionsDelegate!.followingUpdated(selectedOwner!)
                                }
                            })
                            
                        }
                        else
                        {
                            
                            print(response)
                        }
                        
                    }
                    else
                    {
                        
                        print(response)
                    }
                    
                })
        }
    }
    
    
    // CUSTOM METHODS
    
    
    func showAvailableOptions() {
        
        if (self.menusTable == nil) {
            
            let xPos:CGFloat = 10
            let yPos = Common.sharedCommon.calculateDimensionForDevice(70)
            let width = self.frame.size.width - (2 * xPos)
            let height = self.frame.size.height - (2 * yPos)
            
            self.menusTable = UITableView(frame: CGRectMake(xPos,yPos,width,height), style: UITableViewStyle.Grouped)
            self.menusTable!.backgroundColor = self.backgroundColor
            self.menusTable!.separatorStyle = .None
            self.menusTable!.delegate = self
            self.menusTable!.dataSource = self
            self.addSubview(self.menusTable!)
        }

        
    }
    
    func showFollowersTable() {
        
        if (followersTable == nil) {
            
            let xPos:CGFloat = 10
            var yPos = Common.sharedCommon.calculateDimensionForDevice(70)
            if (self.fromSettings == false) {
                
                yPos = 0
            }
            let width = self.frame.size.width - (2 * xPos)
            let height = self.frame.size.height - (2 * yPos)
            
            self.followersTable = UITableView(frame: CGRectMake(xPos,yPos,width,height), style: UITableViewStyle.Grouped)
            self.followersTable!.backgroundColor = self.backgroundColor
            self.followersTable!.separatorStyle = .None
            self.followersTable!.delegate = self
            self.followersTable!.dataSource = self
            self.addSubview(self.followersTable!)
            
            sectionIndexSet = NSMutableIndexSet(index: 0)
            sectionIndexSet!.addIndex(1)
        }
        
        
        let ownerId = Common.sharedCommon.config!["ownerId"] as! String
        let data = ["ownerid" : ownerId]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathGetOwnerDetails , body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            if (result == true) {
                
                self.following.removeAll()
                self.followed.removeAll()
                
                self.followingDict = response["data"]!["following"] as! Dictionary<String,String>
                self.following = Array(self.followingDict.keys)
                
                
                self.followedDict = response["data"]!["followers"] as! Dictionary<String,String>
                self.followed = Array(self.followedDict.keys)
                
            }
            else {
                
                self.following.removeAll()
                self.followed.removeAll()
                
                
                self.following = []
                self.followed = []
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.followersTable!.reloadSections(self.sectionIndexSet!, withRowAnimation: UITableViewRowAnimation.Automatic)
                
            })
            
            
        }
    }
    
    func sectionTapped(sender:UITapGestureRecognizer?) {
        
        var tappedIndex = 0
        
        if (sender != nil)
        {
            tappedIndex = ((sender!.view as? UILabel)?.tag)!
        }
        else
        {
            tappedIndex = 1
        }
        
        rowsInFollowersSection = 0
        rowsInFollowingSection = 0
        
        if (tappedIndex == 0) {
            
            rowsInFollowersSection = self.followed.count
        }
        else if (tappedIndex == 1) {
            
            rowsInFollowingSection = self.following.count
        }
        
        
        self.followersTable!.reloadSections(sectionIndexSet!, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        
    }
    
    func showButtonTapped(sender:CustomButton) {
        
        let section = sender.indexPath!.section
        let row = sender.indexPath!.row
        var selectedOwner:String? = nil
        
        if (section == 0) {
            
            selectedOwner = self.followedDict[self.followed[row]]
        }
        else if (section == 1) {
            
            selectedOwner = self.followingDict[self.following[row]]
        }
        
        if (selectedOwner != nil ) {
            
            
            CacheManager.sharedCacheManager.selectedOwnerNotes = CacheManager.sharedCacheManager.allNotes.filter({$0.ownerID == selectedOwner!})
            
            if (self.optionsOptionsDelegate != nil) {
                
                self.optionsOptionsDelegate!.showNotesForSelectedFollowingOwnerInWall(CacheManager.sharedCacheManager.selectedOwnerNotes)
                
            }
        }
    }
    
    
    func showPinBuyView() {
        
       /* if (self.pinBuyView == nil) {
            
            self.pinBuyView = PinBuy(frame: self.frame,overrideTextColor:UIColor.blackColor())
            //self.pinBuyView!.pinBuyDelegate = self
            self.addSubview(self.pinBuyView!)
        } */
        
        //let paymentController = PaymentController(nibName: nil, bundle: nil, overrideTextColor: nil)
    }
    
    
    func checkPinAvailability() {
        
        let data = ["ownerid" : Common.sharedCommon.config!["ownerId"] as! String]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathGetPins , body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            
            if (result == true) {
                
                let err:String? = response.objectForKey("data")?.objectForKey("error") as? String
                
                if (err == nil) {
                    
                    let data = response.objectForKey("data") as? Dictionary<String,AnyObject>
                    self.showPinBuyView()
                    Common.sharedCommon.showPins(data!, attachView: self, attachPosition: CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5, Common.sharedCommon.calculateDimensionForDevice(70)),delegate:nil)
                    
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
