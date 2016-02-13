//
//  ComposeNoteController.swift
//  Notewall
//
//  Created by Bharath on 24/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit

protocol ComposeDelegate {
    
    func postAWallNote(noteType:String?,noteText:String,noteFont:String,noteFontSize:CGFloat,noteFontColor:Array<CGFloat>)
}


class Compose:UIViewController,UITextViewDelegate,UIScrollViewDelegate,ComposeNoteDelegate,CloseViewProtocolDelegate {
    
    
    var newNoteView:UIView?
    var notesImageView:ComposeNote?
    var noteTypesScroll:SettingsScroll?
    var noteFontsScroll:SettingsScroll?
    var noteFontSizeScroll:SettingsScroll?
    var noteFontColorScroll:SettingsScroll?
    var textField:UITextView?
    var enteredText:String?
    var selectedNoteIndex:Int = 0
    var selectedNoteInNoteIndex:Int = 0
    var selectedFontIndex:Int = 0
    var selectedFontSizeIndex:Int = 15
    var selectedFontColorIndex:Int = 0
    var composeDelegate:ComposeDelegate?
    var orgNotePosition:CGRect?
    var orgNoteCenter:CGPoint?
    
    var currentLine:Int = 1
    var runningLine:Int = 1
    var maxLineForNoteMovement:Int = 3
    var previousLine:Int = -1
    var maxLinesAllowed = 0
    var stickyNotes:Array<String> = []
    var noteAdjustment:CGFloat = 40.0
    
    override func viewDidLoad() {
        
        for noteTypes in kPinNotes {
            
            stickyNotes.append(noteTypes[0])
        }
        
        self.composeNewNote()
        currentLine = maxLineForNoteMovement - 1
        
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    //UIScrollView Delegate Methods
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        if (scrollView == noteTypesScroll!.scrollView!) {
            
            let contentOffset:CGFloat = self.noteTypesScroll!.scrollView!.contentOffset.x
            selectedNoteIndex = Int(contentOffset / self.noteTypesScroll!.scrollView!.frame.size.width)
            self.notesImageView!.image = UIImage(named: stickyNotes[selectedNoteIndex])
            
        }
        
        if (scrollView == noteFontsScroll!.scrollView!) {
            
            let contentOffset:CGFloat = self.noteFontsScroll!.scrollView!.contentOffset.x
            selectedFontIndex = Int(contentOffset / self.noteFontsScroll!.scrollView!.frame.size.width)
            
            self.assignedTextAttributes()
        }
        
        if (scrollView == noteFontSizeScroll!.scrollView!) {
            
            let contentOffset:CGFloat = self.noteFontSizeScroll!.scrollView!.contentOffset.x
            selectedFontSizeIndex = Int(contentOffset / self.noteFontSizeScroll!.scrollView!.frame.size.width)
            
            self.assignedTextAttributes()
            
        }
        
        if (scrollView == noteFontColorScroll!.scrollView!) {
            
            let contentOffset:CGFloat = self.noteFontColorScroll!.scrollView!.contentOffset.x
            selectedFontColorIndex = Int(contentOffset / self.noteFontColorScroll!.scrollView!.frame.size.width)
            
            self.assignedTextAttributes()
        }
        
    }
    
    // Textview Delegate Methods
    
    func textViewDidChange(textView: UITextView) {
        
        self.enteredText = textView.text
        let numLines = Int(textView.contentSize.height / textView.font!.lineHeight)
        runningLine = numLines
        self.checkForMovingview(numLines)
        
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if (runningLine <= maxLinesAllowed) {
            
            return true
        }
        else {
            
            if (text == "") {
                
                return true
            }
            
            return false
        }
    }
    
    // Compose Note Delegate Methods
    
    func composeDismissKeyboard() {
        
        self.dimissKeyboard()
    }
    
    func composeNoteSwipped() {
        
        self.noteSwiped()
    }
    
    // Close View Delegate Methods
    
    func handleCloseViewTap() {
        
        if (textField != nil) {
            
            enteredText = textField!.text!
            textField!.resignFirstResponder()
            textField!.removeFromSuperview()
            textField = nil
        }
        
        if (notesImageView != nil) {
            
            notesImageView!.removeFromSuperview()
            notesImageView = nil
        }
        
        if (newNoteView != nil) {
            
            newNoteView!.removeFromSuperview()
            newNoteView = nil
        }
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            
            
        }

    }
    
    // Custom Methods
    
    func checkForMovingview(numlines:Int) {
        
        var centerOffset:CGFloat = self.orgNoteCenter!.y
        var move:Bool = false
        
        if (runningLine != currentLine && runningLine >= maxLineForNoteMovement) {
            
            if (runningLine > previousLine) {
                
                centerOffset = self.notesImageView!.center.y - noteAdjustment
                move = true
                
            }
            else if (runningLine <= previousLine) {
                print(previousLine)
                centerOffset = self.notesImageView!.center.y + noteAdjustment
                move = true
            }
            
            previousLine = currentLine
            currentLine = runningLine
            
        }
        else {
            
            previousLine = currentLine
            currentLine = runningLine
        }
        
        
        if (runningLine < maxLineForNoteMovement && self.notesImageView!.center.y != self.orgNoteCenter!.y) {
            
            previousLine = -1
            currentLine = maxLineForNoteMovement - 1
            centerOffset = self.orgNoteCenter!.y
            move = true
        }
        
        
        
        if (move == true) {
            
           /* UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                
                self.notesImageView!.center = CGPointMake(self.notesImageView!.center.x, centerOffset)
                
                }, completion: { (Bool) -> Void in
                    
                    
            }) */
            
            moveNoteviewToMatch(move, offset: centerOffset)
            move = false
            
        }
    }
    
    func moveNoteviewToMatch(decision:Bool,offset:CGFloat) {
        
        if (decision == true) {
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                
                self.notesImageView!.center = CGPointMake(self.notesImageView!.center.x, offset)
                
                }, completion: { (Bool) -> Void in
                    
                    
            })
            
        }
        
    }
    
    func dimissKeyboard() {
        
        if (self.textField!.isFirstResponder() == true) {
            
            self.textField!.resignFirstResponder()
            
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                
                    self.notesImageView!.center = self.orgNoteCenter!
                
                }, completion: { (Bool) -> Void in
                    
                
            })
        }
        else {
            
            self.textField!.becomeFirstResponder()
            
            if (runningLine >= maxLineForNoteMovement) {
                
                let offset =  self.notesImageView!.center.y - (noteAdjustment * CGFloat(runningLine - maxLineForNoteMovement + 1))
                print(runningLine)
                print(maxLineForNoteMovement)
                print(previousLine)
                self.moveNoteviewToMatch(true, offset: offset)
            }
        }
    }
    
    func composeNewNote() {
        
        newNoteView = UIView(frame: self.view.frame)
        let bgImage = UIImageView(frame: self.view.frame)
        bgImage.image = UIImage(named: kDefaultBGImageName)
        bgImage.userInteractionEnabled = true
        self.newNoteView!.addSubview(bgImage)
        self.view.addSubview(newNoteView!)
        
        let tap = UITapGestureRecognizer(target: self, action: "dimissKeyboard")
        bgImage.addGestureRecognizer(tap)
        
        for font in kFontSizes {
            
            if (font == 30.0) {
                
                selectedFontSizeIndex = kFontSizes.indexOf(font)!
            }
        }
        
        let buttonWidth = Common.sharedCommon.calculateDimensionForDevice(80)
        let buttonHeight = Common.sharedCommon.calculateDimensionForDevice(35)
        
        
        var xOffset = kScreenWidth * 0.5 - (buttonWidth * 0.5)
        var yOffset = Common.sharedCommon.calculateDimensionForDevice(10)
        let postButton = CustomButton(frame: CGRectMake(xOffset, yOffset, buttonWidth, buttonHeight), buttonTitle: kButtonPostText, normalColor: UIColor.redColor(), highlightColor: UIColor.blackColor())
        postButton.addTarget(self, action: "postTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        self.newNoteView!.addSubview(postButton)
        
        /*let closeImage = UIImageView(frame: CGRectMake(kScreenWidth - Common.sharedCommon.calculateDimensionForDevice(30), Common.sharedCommon.calculateDimensionForDevice(5), Common.sharedCommon.calculateDimensionForDevice(30), Common.sharedCommon.calculateDimensionForDevice(30)))
        closeImage.image = UIImage(named: "close.png")
        closeImage.userInteractionEnabled = true
        self.newNoteView!.addSubview(closeImage)
        let closeImgTap = UITapGestureRecognizer(target: self, action: "cancelTapped:")
        closeImage.addGestureRecognizer(closeImgTap) */
        
        let closeImage = CloseView(frame: CGRectMake(kScreenWidth - Common.sharedCommon.calculateDimensionForDevice(30), Common.sharedCommon.calculateDimensionForDevice(5), Common.sharedCommon.calculateDimensionForDevice(30), Common.sharedCommon.calculateDimensionForDevice(30)))
        closeImage.closeViewDelegate = self
        self.newNoteView!.addSubview(closeImage)
        
        
        xOffset = 10.0
        yOffset = kScreenHeight * 0.15
        
        var frameRect = CGRectMake(xOffset,yOffset,Common.sharedCommon.calculateDimensionForDevice(100),Common.sharedCommon.calculateDimensionForDevice(120))
        
        noteTypesScroll = SettingsScroll(frame: frameRect, fillSettings: stickyNotes, contentTypeTitle: "NOTES")
        noteTypesScroll!.scrollView!.delegate = self
        noteTypesScroll!.hidden = false
        self.newNoteView!.addSubview(noteTypesScroll!)
        
        xOffset = self.noteTypesScroll!.frame.origin.x + self.noteTypesScroll!.frame.size.width + Common.sharedCommon.calculateDimensionForDevice(10)
        yOffset = Common.sharedCommon.calculateDimensionForDevice(30)
        let width = kScreenWidth - (xOffset * 2)
        
       /* notesImageView = UIImageView(frame: CGRectMake(xOffset,yOffset,width,width * 0.90))
        notesImageView!.image = UIImage(named: stickyNotes[0])
        notesImageView!.userInteractionEnabled = true
        self.newNoteView!.addSubview(notesImageView!)
        let noteTap = UITapGestureRecognizer(target: self, action: "dimissKeyboard")
        notesImageView!.addGestureRecognizer(noteTap)
        orgNotePosition = notesImageView!.frame
        orgNoteCenter = notesImageView!.center
        let noteSwipe = UISwipeGestureRecognizer(target: self, action: "noteSwiped")
        noteSwipe.direction = .Down
        notesImageView!.addGestureRecognizer(noteSwipe)
        
       /* xOffset = self.noteTypesScroll!.frame.origin.x + self.noteTypesScroll!.frame.size.width + Common.sharedCommon.calculateDimensionForDevice(10)
        yOffset = Common.sharedCommon.calculateDimensionForDevice(50)
        width = kScreenWidth - (xOffset * 2) */
        let textFieldFrame = CGRectInset(notesImageView!.frame, Common.sharedCommon.calculateDimensionForDevice(40), Common.sharedCommon.calculateDimensionForDevice(40))
        
        //textField = UITextView(frame: CGRectMake(xOffset,yOffset,width,width))
        textField = UITextView(frame: textFieldFrame)
        textField!.delegate = self
        textField!.backgroundColor = UIColor.clearColor()
        textField!.textColor = Common.sharedCommon.formColorWithRGB(kFontColor[0])
        textField!.font = UIFont(name: "Chalkduster", size: kFontSizes[selectedFontSizeIndex])
        self.newNoteView!.addSubview(textField!)
        textField!.becomeFirstResponder()
        textField!.hidden = false
        //self.enteredText = "Hello"
        //self.showPreviewImage() */
        
        let noteFrame = CGRectMake(xOffset,yOffset,width,width * 0.90)
        notesImageView = ComposeNote(frame: noteFrame, withImage: stickyNotes[0], withFontIndex:selectedFontSizeIndex)
        notesImageView!.composeNoteDelegate = self
        orgNotePosition = notesImageView!.frame
        orgNoteCenter = notesImageView!.center
        textField = notesImageView!.composeTextView
        textField!.delegate = self
        self.newNoteView!.addSubview(notesImageView!)
       
        
        xOffset = self.notesImageView!.frame.origin.x + self.notesImageView!.frame.size.width + Common.sharedCommon.calculateDimensionForDevice(10)
        yOffset = self.noteTypesScroll!.frame.origin.y
        frameRect = CGRectMake(xOffset,yOffset,noteTypesScroll!.frame.size.width,noteTypesScroll!.frame.size.height)
        
        noteFontsScroll = SettingsScroll(frame: frameRect, fillSettings: kSupportedFonts, contentTypeTitle:"FONTS")
        noteFontsScroll!.scrollView!.delegate = self
        noteFontsScroll!.hidden = false
        self.newNoteView!.addSubview(noteFontsScroll!)
        
        
        xOffset = self.noteTypesScroll!.frame.origin.x
        yOffset = self.noteTypesScroll!.frame.origin.y + self.noteTypesScroll!.frame.size.height + Common.sharedCommon.calculateDimensionForDevice(15)
        frameRect = CGRectMake(xOffset,yOffset,noteTypesScroll!.frame.size.width,noteTypesScroll!.frame.size.height)
        
        noteFontSizeScroll = SettingsScroll(frame: frameRect, fillSettings: kFontSizes, contentTypeTitle:"SIZE")
        noteFontSizeScroll!.scrollView!.delegate = self
        noteFontSizeScroll!.hidden = false
        self.newNoteView!.addSubview(noteFontSizeScroll!)
        
        
        xOffset = noteFontSizeScroll!.frame.size.width * CGFloat(selectedFontSizeIndex)
        yOffset = noteFontSizeScroll!.scrollView!.frame.origin.y
        noteFontSizeScroll!.scrollView!.scrollRectToVisible(CGRectMake(xOffset, yOffset, noteFontSizeScroll!.scrollView!.frame.size.width,noteFontSizeScroll!.scrollView!.frame.size.height), animated: false)
        
        xOffset = self.noteFontsScroll!.frame.origin.x
        yOffset = self.noteFontSizeScroll!.frame.origin.y
        frameRect = CGRectMake(xOffset,yOffset,noteTypesScroll!.frame.size.width,noteTypesScroll!.frame.size.height)
        
        noteFontColorScroll = SettingsScroll(frame: frameRect, fillSettings: kFontColor, contentTypeTitle:"COLORS")
        noteFontColorScroll!.scrollView!.delegate = self
        noteFontColorScroll!.hidden = false
        self.newNoteView!.addSubview(noteFontColorScroll!)
        
        self.assignedTextAttributes()
        
    }
    
   /* func addTextField() {
        
        textField = UITextView(frame: notesImageView!.frame)
        textField!.delegate = self
        textField!.backgroundColor = UIColor.clearColor()
        textField!.textColor = UIColor.whiteColor()
        textField!.font = UIFont(name: "Chalkduster", size: 18.0)
        self.newNoteView!.addSubview(textField!)
        textField!.becomeFirstResponder()
        self.enteredText = "Hello"
        self.showPreviewImage()
        
    } */
    
    func showPreviewImage() {
        
        if (enteredText == nil ) {
            
            enteredText = ""
        }
        
        self.notesImageView!.image = nil
        let imageFileName = kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex]
        
        let preImg = Common.sharedCommon.textToImage(enteredText!, inImage: UIImage(named: imageFileName)!, atPoint: CGPointMake(0, 0), preferredFont:kSupportedFonts[selectedFontIndex], preferredFontSize: kFontSizes[selectedFontSizeIndex],preferredFontColor: Common.sharedCommon.formColorWithRGB(kFontColor[selectedFontColorIndex]),addExpiry:false,expiryDate:nil)
        
        self.notesImageView!.image = preImg
    }
    
    
    func assignedTextAttributes() {
        
        let fontSize = kFontSizes[selectedFontSizeIndex]
        let font = kSupportedFonts[selectedFontIndex]
        let color = Common.sharedCommon.formColorWithRGB(kFontColor[selectedFontColorIndex])
        
        self.textField!.font = UIFont(name: font, size: fontSize);
        self.textField!.textColor = color
        //maxLinesAllowed = Int(self.notesImageView!.frame.size.height / kFontSizes[selectedFontSizeIndex]) - 1
        //maxLinesAllowed = Int(self.textField!.frame.size.height / kFontSizes[selectedFontSizeIndex]) - 2
        
        let fSize = kFontSizes[selectedFontSizeIndex]
        if ( fSize < 17) {
            
            maxLineForNoteMovement = 4
            maxLinesAllowed = 7
            
        }
        else if (fSize >= 17 && fSize < 26) {
            
            maxLineForNoteMovement = 3
            maxLinesAllowed = 6
        }
        else if (fSize >= 26 && fSize < 45) {
            
            maxLineForNoteMovement = 2
            maxLinesAllowed = 5
        }
        else if (fSize >= 45) {
            
            maxLineForNoteMovement = 1
            maxLinesAllowed = 2
        }
        
    }
    
   /* func previewTapped(sender:CustomButton) {
        
        if (sender.titleLabel!.text! == kButtonPreviewText) {
            
            let characterCount = textField!.text!.characters.count
            
            if (characterCount >= kMinRequiredCharacters) {
                
               /* noteTypesScroll!.hidden = false
                noteFontsScroll!.hidden = false
                noteFontSizeScroll!.hidden = false
                noteFontColorScroll!.hidden = false */
                
                textField!.resignFirstResponder()
                sender.setTitle(kButtonEditText, forState: UIControlState.Normal)
                enteredText = textField!.text
                textField!.removeFromSuperview()
                textField = nil
                
                self.showPreviewImage()
                
            }
            
        }
        else if (sender.titleLabel!.text! == kButtonEditText) {
            
           /* noteTypesScroll!.hidden = true
            noteFontsScroll!.hidden = true
            noteFontSizeScroll!.hidden = true
            noteFontColorScroll!.hidden = true */
            
            //self.addTextField()
            textField!.becomeFirstResponder()
            sender.setTitle(kButtonPreviewText, forState: UIControlState.Normal)
            
            self.notesImageView!.image = UIImage(named: stickyNotes[selectedNoteIndex])!
            
            textField!.text = enteredText!
        }
       
        
        
    } */
    
    func postTapped(sender:CustomButton) {
        
        var characterCount:Int?
        
        if (textField != nil) {
            
            characterCount = textField!.text!.characters.count
        }
        else {
            
            characterCount = enteredText!.characters.count
            
        }
        
        
        if (characterCount >= kMinRequiredCharacters) {
            
            
            if (textField != nil) {
                
                enteredText = textField!.text!
                textField!.resignFirstResponder()
                textField!.removeFromSuperview()
                textField = nil
            }
            
            if (notesImageView != nil) {
            
                notesImageView!.removeFromSuperview()
                notesImageView = nil
            }
            
            if (newNoteView != nil) {
            
                newNoteView!.removeFromSuperview()
                newNoteView = nil
            }
            
            if (composeDelegate != nil) {
                
                self.composeDelegate!.postAWallNote(stickyNotes[selectedNoteIndex], noteText: enteredText!, noteFont: kSupportedFonts[selectedFontIndex], noteFontSize: kFontSizes[selectedFontSizeIndex], noteFontColor: kFontColor[selectedFontColorIndex])
            }
            
            self.dismissViewControllerAnimated(true) { () -> Void in
            
            
            }
            
        }
        else {
            
            print("Need atleast 20 charatcers")
        }
        
    }
    
  /*  func cancelTapped(sender:AnyObject) {
        
        if (textField != nil) {
            
            enteredText = textField!.text!
            textField!.resignFirstResponder()
            textField!.removeFromSuperview()
            textField = nil
        }
        
        if (notesImageView != nil) {
            
            notesImageView!.removeFromSuperview()
            notesImageView = nil
        }
        
        if (newNoteView != nil) {
            
            newNoteView!.removeFromSuperview()
            newNoteView = nil
        }
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            
            
        }
        
    } */
    
    func noteSwiped() {
        
        let animateImgView = UIImageView(frame: self.notesImageView!.frame)
        animateImgView.image = UIImage(named:kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex])
        self.view.addSubview(animateImgView)
        
        selectedNoteInNoteIndex = selectedNoteInNoteIndex + 1
        let notes = kPinNotes[selectedNoteIndex]
        
        if (selectedNoteInNoteIndex >= notes.count) {
            
            selectedNoteInNoteIndex = 0
        }
        
        self.notesImageView!.image = UIImage(named:kPinNotes[selectedNoteIndex][selectedNoteInNoteIndex])
        
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
                animateImgView.center = CGPointMake(animateImgView.center.x, animateImgView.center.y + kScreenHeight)
            
            }) { (Bool) -> Void in
                
                animateImgView.removeFromSuperview()
                
        }
        
       
    }
    
    
    
}
