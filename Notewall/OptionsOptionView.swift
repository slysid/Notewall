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
    func showNotesForSelectedFollowingOwner(dataList:NSArray)
}

class OptionsOptionView:UIView,UITableViewDataSource,UITableViewDelegate {
    
    var followersTable:UITableView?
    let tableSectionHeight:CGFloat = 40
    var sectionIndexSet:NSMutableIndexSet?
    var rowsInFollowingSection = 0
    var rowsInFollowersSection = 0
    var followingDict:Dictionary<String,String> = [:]
    var following:Array<String> = []
    var followedDict:Dictionary<String,String> = [:]
    var followed:Array<String> = []
    var optionsOptionsDelegate:OptionsOptionViewProtocolDelegate?
    
    override init(frame: CGRect) {
        
        super.init(frame:frame)
        
        self.backgroundColor = kOptionsBgColor
        
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
        
        
        self.showFollowersTable()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TABLEVIEW DELEGATE METHODS
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            
            return rowsInFollowersSection
        }
        else if (section == 1) {
            
            return rowsInFollowingSection
        }
        else {
            
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if (cell == nil) {
            
            cell = UITableViewCell(style: UITableViewCellStyle.Default , reuseIdentifier: "cell")
            cell?.textLabel!.backgroundColor = self.backgroundColor
            cell?.contentView.backgroundColor = self.backgroundColor
            cell?.textLabel!.textColor = UIColor.blackColor()
            
            let bgView = UIView()
            bgView.backgroundColor = self.backgroundColor
            bgView.userInteractionEnabled = true
            cell?.selectedBackgroundView = bgView
            
            
            let showButton = CustomButton(frame: CGRectMake(0,0,Common.sharedCommon.calculateDimensionForDevice(70) ,cell!.contentView.frame.size.height), buttonTitle: "Show", normalColor: UIColor.whiteColor(), highlightColor: nil)
            showButton.userInteractionEnabled = true
            showButton.center = CGPointMake(cell!.contentView.frame.size.width - (showButton.frame.size.width * 0.75), cell!.contentView.frame.size.height * 0.5)
            showButton.indexPath = indexPath
            //showButton.setTitle("Show", forState: UIControlState.Normal)
            //showButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            showButton.addTarget(self, action: "showButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            showButton.hidden = true
            cell!.contentView.addSubview(showButton)
            
        }
        
        if (indexPath.section == 0) {
            
            cell?.textLabel!.text = self.followed[indexPath.row]
        }
        else if (indexPath.section == 1) {
            
            cell?.textLabel!.text = self.following[indexPath.row]
        }
        
        
        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        let sectionLabel = UILabel(frame: CGRectMake(0,0,self.followersTable!.frame.size.width,tableSectionHeight))
        sectionLabel.textAlignment = NSTextAlignment.Center
        sectionLabel.textColor = UIColor.blackColor()
        sectionLabel.font = UIFont(name: "Roboto", size: 24.0)
        sectionLabel.tag = section
        sectionLabel.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "sectionTapped:")
        sectionLabel.addGestureRecognizer(tap)
        
        
        if (section == 0) {
            
            sectionLabel.text = "Followers-(" + String(self.followed.count) + ")"
        }
        else if (section == 1) {
            
            sectionLabel.text = "Following-(" + String(self.following.count) + ")"
        }
        
        return sectionLabel
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return tableSectionHeight
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
       /* var selectedOwner:String?
        
        let section = indexPath.section
        let row = indexPath.row
    
        if (section == 0) {
            
            selectedOwner = self.followed[row]
        }
        else if (section == 1) {
            
            selectedOwner = self.following[row]
        } */
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        for b in cell!.contentView.subviews {
            
            if b is UIButton {
                
                (b as? UIButton)!.hidden = false
            }
        }
    }
    
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        for b in cell!.contentView.subviews {
            
            if b is UIButton {
                
                (b as? UIButton)!.hidden = true
            }
        }
        
    }
    
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
         return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        for b in cell!.contentView.subviews {
            
            if b is UIButton {
                
                (b as? UIButton)!.hidden = true
            }
        }

    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            
            let section = indexPath.section
            let row = indexPath.row
            let ownerName = tableView.cellForRowAtIndexPath(indexPath)?.textLabel!.text
            var selectedOwner:String?
            
            if (section == 0) {
                
                self.followed.removeAtIndex(row)
                selectedOwner = self.followedDict[ownerName!]
            }
            else if (section == 1) {
                
                self.following.removeAtIndex(row)
                selectedOwner = self.followingDict[ownerName!]
            }
            
            rowsInFollowersSection = self.followed.count
            rowsInFollowingSection = self.following.count
            
            let ownerID = Common.sharedCommon.config!["ownerId"] as! String
            let paramData = NSDictionary(objects: [selectedOwner!], forKeys: ["<followownerid>"])
            let data = ["ownerid" : ownerID]
            
            Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathFollow, body: data, replace: paramData, requestContentType: kContentTypes.kApplicationJson, completion: { (result, response) -> Void in
                
                if (result == true) {
                    
                    if (response["error"] == nil) {
                        
                        dispatch_async(dispatch_get_main_queue() , { () -> Void in
                            
                            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
                            
                            if (self.optionsOptionsDelegate != nil) {
                                
                                self.optionsOptionsDelegate!.followingUpdated(selectedOwner!)
                            }
                        })
                        
                    }
                    else {
                        
                        print(response)
                    }
                    
                }
                else {
                    
                    print(response)
                }
                
            })
            
        }
    }
    
    
    // CUSTOM METHODS
    
    func showFollowersTable() {
        
        if (followersTable == nil) {
            
            let xPos:CGFloat = 10
            let yPos = Common.sharedCommon.calculateDimensionForDevice(70)
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
    }
    
    func sectionTapped(sender:UITapGestureRecognizer) {
        
        let tappedIndex = (sender.view as? UILabel)?.tag
        
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
            
            
            let selectedOwnerPredicate = NSPredicate(format: "ownerID = %@", selectedOwner!)
            
            CacheManager.sharedCacheManager.selectedOwnerNotesDataList = ((CacheManager.sharedCacheManager.allNotesDataList as NSArray).filteredArrayUsingPredicate(selectedOwnerPredicate) as? Array<Dictionary<String,AnyObject>>)!
            
            if (self.optionsOptionsDelegate != nil) {
                
                self.optionsOptionsDelegate!.showNotesForSelectedFollowingOwner(CacheManager.sharedCacheManager.selectedOwnerNotesDataList)
            }
        }
    }
}
