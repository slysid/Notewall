//
//  Constants.swift
//  Notewall
//
//  Created by Bharath on 23/01/16.
//  Copyright © 2016 Bharath. All rights reserved.
//

import Foundation
import UIKit



enum kAllowedPaths {
    
    case kPathHealth
    case kPathRegister
    case kPathGetAllNotes
    case kPathAddNoteToFav
    case kPathRemoveNote
    case kPathPostNewNote
    case kPathGetNotesForOwner
    case kPathGetFavNotesForOwner
    case kPathGetImage
    case kPathFollow
    case kPathPoll
    case kPathUpdateScreenName
    case kPathUpdatePaswword
    case kPathGetOwnerDetails
}

enum kRunModes {
    
    case modeLive
    case modeDebug
}

enum kComposeTypes {
    
    case kComposeNote
    case kComposePicture
}

enum kContentTypes {
    
    case kApplicationJson
    case kMultipartFormData
    case kNoContentType
}

let kPhone = "phone"
let kPad = "pad"
let kNoteDim:CGFloat = 100.0
let kBlownupNoteDim:CGFloat = 300.0
let kMinRequiredCharacters = 0
let kDefaultFont = "Helvetica"
let kDefaultFontColor = UIColor.blackColor()
let kButtonPreviewText = "Preview"
let kButtonPostText = "Post"
let kButtonEditText = "Edit"
let kButtonCancelText = "Cancel"
let kSocialScreenName = "socialscreenname"

let kTimeoutApp:NSTimeInterval = 60000
let kLoggedInYetToLogin = "YETTOLOGIN"
let kLoggedinThroughGoogle = "GOOGLE"
let kLoggedinThroughFB = "FB"
let kLoggedinThroughMail = "Mail"

let kKeyPolaroid = "polaroid"
let kKeyPolaroidThumbNail = "thumbnail"

var kScreenWidth = UIScreen.mainScreen().bounds.size.width
var kScreenHeight = UIScreen.mainScreen().bounds.size.height

let kDefaultBGImageName = "bg1.png"
let kBG1:[String:Any] = ["bg":"bg1.png","datasource":kAllowedPaths.kPathGetAllNotes,"icon":"notes.png"]
let kBG2:[String:Any] = ["bg":"bg2.jpg","datasource":kAllowedPaths.kPathGetNotesForOwner,"icon":"my.png"]
let kBG3:[String:Any] = ["bg":"bg3.jpg","datasource":kAllowedPaths.kPathGetFavNotesForOwner,"icon":"heart.png"]
let kBackGrounds = [kBG1,kBG2,kBG3]

/*let kStickyNotes = ["noteBlue1.png",
    "noteGreen1.png","notePink1.png",
    "noteWhite1.png",
    "noteYellow1.png" ] */

let kPinNotes = [
["noteBlue1.png","noteGreen1.png","notePink1.png","noteWhite1.png","noteYellow1.png"],
["noteBlue2.png","noteGreen2.png","notePink2.png","noteWhite2.png","noteYellow2.png"],
["noteBlue3.png","noteGreen3.png","notePink3.png","noteWhite3.png","noteYellow3.png"],
["noteBlue4.png","noteGreen4.png","notePink4.png","noteWhite4.png","noteYellow4.png"],
]

let kComposeTypesData = [["icon": "noteBlue1.png"],
                          ["icon":"camera.png"]]

let kDefaultNoteType = kPinNotes[0][0]


let kSupportedFonts = ["Chalkduster",
                       "ChalkboardSE-Bold",
                       "MarkerFelt-Wide",
                       "Verdana-Bold"]

let kFontSizes:Array<CGFloat> = [15.0,16.0,17.0,18.0,19.0,20.0,21.0,22.0,23.0,24.0,25.0,26.0,27.0,28.0,29.0,30.0,35.0,40.0,45.0,50.0,55.0,60.0]

let kFontColor:Array<Array<CGFloat>> = [[0.0,0.0,0.0], [255.0,0.0,0.0],[0.0,255.0,0.0],[255.0,255.0,0.0],[96.0,96.0,96.0]]

let kStickyNoteFontSize:CGFloat = 28.0

let kRunMode = kRunModes.modeLive
let kHttpProtocol = "http"
let kHttpHost = "192.168.0.12" //"172.17.50.170" //"192.168.0.12"
let kHttpPaths = [["path" : "/api/health", "method" : "GET" ],
                  ["path" : "/api/owner/register", "method" : "POST" ],
                  ["path" : "/api/notes/all", "method" : "POST"],
                  ["path" : "/api/notes/<noteid>/favorite", "method" : "PUT"],
                  ["path" : "/api/notes/<noteid>/remove", "method" : "DELETE"],
                  ["path" : "/api/notes/post", "method" : "POST"],
                  ["path" : "/api/notes/all/owner", "method" : "POST"],
                  ["path" : "/api/notes/all/favs", "method" : "POST"],
                  ["path" : "/api/uploads/<filename>","method" : "GET"],
                  ["path" : "/api/owner/follow/<followownerid>","method" : "PUT"],
                  ["path" : "/api/poll","method" : "POST"],
                  ["path" : "/api/owner/update/screenname","method" : "PUT"],
                  ["path" : "/api/owner/update/password","method" : "PUT"],
                  ["path" : "/api/owner/details","method" : "POST"]
]


let kAllowedContentTypes = ["application/json","multipart/form-data",""]
let kDebugHealthResponse = ["api":"OK","database":"OK"]
let kDebugAllNotesResponse = [ "data" : [
                                         ["notedID" : "56bb9dbe8b634e5bbaae4f5a",
                                          "notepinned":false,
                                          "noteText":"debugNote1",
                                          "noteTextColor":[255.0,0.0,0.0],
                                          "noteTextFont" : "Chalkduster",
                                          "noteTextFontSize":30.0,
                                          "noteType":"noteBlue1.png",
                                          "exclusions": [],
                                          "owners" : []],
    
                                         ["notedID" : "56bb9dbe8b634e5bbaae4f5b",
                                         "notepinned":false,
                                         "noteText":"debugNote2",
                                         "noteTextColor":[255.0,0.0,0.0],
                                         "noteTextFont" : "Chalkduster",
                                         "noteTextFontSize":30.0,
                                         "noteType":"noteBlue1.png",
                                         "exclusions": [],
                                         "owners" : []]
    
    ]]


let kMenuOptions = [1:["title":"GENERAL","icon":"home.png","selector":"optionItemGeneral"],2:["title":"LOGOUT","icon":"logout.png","selector":"optionItemLogout"]]
let kGeneralMenuOptions = [1:["title":"PROFILE","icon":"my.png","selector":"optionItemProfile"],2:["title":"OPTIONS","icon":"options.png","selector":"optionItemOptions"],3:["title":"ABOUT","icon":"noteBlue3.png","selector":"optionItemAbout"]]

let kOptionsBgColor = UIColor(red: CGFloat(195.0/255.0), green: CGFloat(58.0/255.0), blue: (58.0/255.0), alpha: 1.0)


var kDevice:String {

    get {
    
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
        
            return kPhone
        }
        else {
        
            return kPad
        }
    }
}
