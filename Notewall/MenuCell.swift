//
//  MenuCell.swift
//  Pin!t
//
//  Created by Bharath on 05/04/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

class MenuCell:UITableViewCell {
    
    var menuImage:UIImageView?
    var menuLabel:UILabel?
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, labelString:String, imageName:String) {
        
        super.init(style:style, reuseIdentifier: reuseIdentifier!)
        
        let menuRect = CGRectMake(0,0,self.contentView.frame.size.height,self.contentView.frame.size.height)
        self.menuImage = UIImageView(frame: CGRectInset(menuRect,5,5))
        self.menuImage!.image = UIImage(named: imageName)
        self.contentView.addSubview(self.menuImage!)
        
        self.menuLabel = UILabel(frame:CGRectMake(self.menuImage!.frame.size.width + 50,0,self.contentView.frame.size.width - self.menuImage!.frame.size.width,self.contentView.frame.size.height))
        self.menuLabel!.text = labelString
        self.menuLabel!.textColor = UIColor.blackColor()
        self.menuLabel!.font = UIFont(name: "Roboto", size: 20.0)
        self.contentView.addSubview(self.menuLabel!)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
