//
//  OptionsOptionView.swift
//  Pinwall
//
//  Created by Bharath on 27/02/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

class OptionsOptionView:UIView,UITableViewDataSource,UITableViewDelegate {
    
    var followersTable:UITableView?
    let tableSectionHeight:CGFloat = 40
    var sectionIndexSet:NSMutableIndexSet?
    var rowsInFollowingSection = 0
    var rowsInFollowersSection = 0
    var following:Array<String> = []
    var followed:Array<String> = []
    
    override init(frame: CGRect) {
        
        super.init(frame:frame)
        
        self.backgroundColor = kOptionsBgColor
        
        let ownerId = Common.sharedCommon.config!["ownerId"] as! String
        let data = ["ownerid" : ownerId]
        
        Common.sharedCommon.postRequestAndHadleResponse(kAllowedPaths.kPathGetOwnerDetails , body: data, replace: nil, requestContentType: kContentTypes.kApplicationJson) { (result, response) -> Void in
            
            if (result == true) {
                
                self.following.removeAll()
                self.followed.removeAll()
                
                let following = response["data"]!["followingnames"]
                
                if (following != nil) {
                    
                    self.following = following as! Array<String>
                }
                else {
                    
                    self.following = []
                }
                
                let followed = response["data"]!["followersnames"]
                
                if (followed != nil) {
                    
                    self.followed = followed as! Array<String>
                }
                else {
                    
                    self.followed = []
                }
                
            }
            else {
                
                self.following.removeAll()
                self.followed.removeAll()
                
                
                self.following = []
                self.followed = []
            }
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
        sectionLabel.textColor = UIColor.whiteColor()
        sectionLabel.font = UIFont(name: "Roboto", size: 24.0)
        sectionLabel.tag = section
        sectionLabel.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "sectionTapped:")
        sectionLabel.addGestureRecognizer(tap)
        
        
        if (section == 0) {
            
            sectionLabel.text = "Followers"
        }
        else if (section == 1) {
            
            sectionLabel.text = "Following"
        }
        
        return sectionLabel
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return tableSectionHeight
    }
    
    
    // CUSTOM METHODS
    
    func showFollowersTable() {
        
        if (followersTable == nil) {
            
            let xPos:CGFloat = 10
            let yPos = Common.sharedCommon.calculateDimensionForDevice(70)
            let width = self.frame.size.width - (2 * xPos)
            let height = self.frame.size.height - (2 * yPos)
            
            self.followersTable = UITableView(frame: CGRectMake(xPos,yPos,width,height), style: UITableViewStyle.Grouped)
            self.followersTable!.backgroundColor = kOptionsBgColor
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
}
