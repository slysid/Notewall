#!/usr/bin/python

from mongoengine import *
from app import Configuration
from app.models.Notes import Notes
from app.models.Owners import Owners
from datetime import datetime, timedelta
from time import strftime
from PIL import Image
import gridfs
import os
import pymongo
import boto.ses
from app.managers.emailmanager import EmailManager
from app.managers.authentication import Authentication, hashPassword, checkPassword
import logging

authentication = Authentication()


def formNoteDict(note,ownerid):
     
     doc = {}
     doc['noteID'] = str(note.id)
     doc['ownerID'] = str(note.ownerId.id)
     doc['noteType'] = note.noteType
     doc['noteText'] = note.noteText
     doc['noteTextColor'] = note.noteTextColor
     doc['noteTextFontSize'] = note.noteTextFontSize
     doc['noteTextFont'] = note.noteTextFont
     doc['notePinned'] = note.notePinned
     doc['owners'] = note.favedOwners
     doc['exclusions'] = note.excludedOwners
     doc['creationDate'] = note.creationDate
     doc['deletionDate'] = note.noteDeletionDate
     doc['noteProperty'] = note.noteProperty
     doc['imageurl'] = note.imageURL
     doc['pinPoint'] = note.pinPoint
     
     for o in Owners.objects(id=doc['ownerID']):
          doc['screenName'] = o.screenName
          if ownerid in o.followers:
               doc['followingNoteOwner'] = True
          else:
               doc['followingNoteOwner'] = False
     
     return doc
     


class NoteQueries():
     
     def __init__(self):
          
          self.logger = logging.getLogger(__name__)
          self.host = Configuration['mongodb']['uri']
          connect('notes',host=self.host)
          
          
     def getCount(self,ownerid):
               return {"data" : {"count" :Notes.objects(noteDeletionDate__gt=datetime.now()).count()}}
     
     
     def getAllNotes(self,ownerid):
          
          allNotes = []
          
          try:
               for note in Notes.objects(noteDeletionDate__gt=datetime.now()):
                    if ownerid not in note.excludedOwners:
                         doc = formNoteDict(note,ownerid)
                         allNotes.append(doc)
          except Exception, e:
               self.logger.error('getAllNotes_Exception')
               self.logger.error(str(e),exc_info=True)
               return {"data" : []}
          
          return {"data" : allNotes }
     
     
     def getAllNotesForOwner(self,ownerid):
          
          allNotes = []
          
          try:
               for note in Notes.objects(Q(ownerId=ownerid) & Q(noteDeletionDate__gt=datetime.now())):
                    if ownerid not in note.excludedOwners:
                         doc = formNoteDict(note,ownerid)
                         allNotes.append(doc)
          except Exception, e:
               self.logger.error('getAllNotesForOwner_Exception')
               self.logger.error(str(e),exc_info=True)
               return {"data" : []}
              
          return {"data" : allNotes }
     
     
     def getAllFavNotesForOwner(self,ownerid):
          
          notesList = []
          allNotes = []
          
          try:
               
               for o in Owners.objects(id=ownerid):
                    notesList = o.favorites
               
               for noteid in notesList:
                    for note in Notes.objects(Q(id=noteid) & Q(noteDeletionDate__gt=datetime.now())):
                              doc = formNoteDict(note,ownerid)
                              allNotes.append(doc)
          except Exception, e:
               self.logger.error('getAllNotesFav_Exception')
               self.logger.error(str(e),exc_info=True)
               return {"data" : []}
              
          return {"data" : allNotes }
     
     
     
     def addNotesToFav(self,noteid,ownerid):
          
          ownerUpate = False
          noteUpdate = False
          excludeUpdate = False
          
          try:
               for n in Notes.objects(id=noteid):
                   note = n
               favedOwners = note.favedOwners
               if ownerid not in favedOwners:
                    favedOwners.append(str(ownerid))
                    note.favedOwners = favedOwners
                    ownerUpate = True
               else:
                    favedOwners.remove(str(ownerid))
                    note.favedOwners = favedOwners
                    ownerUpate = True
                    
               excludedOwners = note.excludedOwners
               if ownerid in excludedOwners:
                    excludedOwners.remove(ownerid)
                    note.excludedOwners = excludedOwners
                    excludeUpdate = True
                
               for o in Owners.objects(id=ownerid):
                    owner = o
               
               favorites = owner.favorites
               if noteid not in favorites:
                    favorites.append(str(noteid))
                    owner.favorites = favorites
                    noteUpdate = True
               else:
                    favorites.remove(str(noteid))
                    owner.favorites = favorites
                    noteUpdate = True
               
               if ownerUpate == True and noteUpdate == True:
                         note.save()
                         owner.save()
               

          except Exception, e:
               self.logger.error('AddNotes_Exception')
               self.logger.error(str(e),exc_info=True)
               return {"data" : {"error":"error in updating fav to notes"}}
          
          return {"data" : {"success":"OK"}}
     
     
     def removeNoteForOwner(self,noteid,ownerid):
          
          excludeUpdate = False
          favUpdate = False
          ownUpdate = False
          dataInAllList = False
          
          try:
               for n in Notes.objects(id=noteid):
                    note = n
                    
               for o in Owners.objects(id=ownerid):
                    owner = o
                    
               
               excludedOwners = note.excludedOwners
               if ownerid not in excludedOwners:
                    excludedOwners.append(ownerid)
                    note.excludedOwners = excludedOwners
                    excludeUpdate = True
                    
               favedOwners = note.favedOwners
               if ownerid in favedOwners:
                    favedOwners.remove(ownerid)
                    note.favedOwners = favedOwners
                    favUpdate = True
                    
               favorites = owner.favorites
               
               if noteid in favorites:
                    dataInAllList = True
                    favorites.remove(noteid)
                    owner.favorites = favorites
                    ownUpdate = True
               
               if dataInAllList == True:
                    if excludeUpdate == True and favUpdate == True and ownUpdate == True:
                         note.save()
                         owner.save()
               else:
                    if excludeUpdate == True or favUpdate == True:
                         note.save()
                         owner.save
                         
               if note.ownerId.id == owner.id:
                    note.delete()          
               
          except Exception, e:
               self.logger.error('removeNoteForOwner_Exception')
               self.logger.error(str(e),exc_info=True)
               return {"data" : {"error":"error in removing notes"}}
          
          return {"data" : {"success":"OK"}}
     
     
     def postNewNote(self,postdata):
          
          try:
               note = Notes()
               
               for o in Owners.objects(id=postdata['ownerid']):
                    owner = o
               
               note.ownerId = owner
               note.noteType = postdata['notetype']
               note.noteText = postdata['notetext']
               note.noteTextColor = postdata['notetextcolor']
               note.noteTextFontSize = postdata['notetextfontsize']
               note.noteTextFont = postdata['notetextfont']
               note.notePinned = postdata['notepinned']
               note.creationDate = datetime.now()
               days = 3
               if postdata['pintype'] == 'Bronze':
                    days = 7
               elif postdata['pintype'] == 'Silver':
                    days = 15
               elif postdata['pintype'] == 'Gold':
                    days = 40
               if note.notePinned == True:
                    note.noteDeletionDate = datetime.now() + timedelta(days=days)
                    ownerQ = OwnerQueries()
                    ownerQ.updatePinCount(postdata['ownerid'],postdata['pintype'],-1)
               else:
                    note.noteDeletionDate = datetime.now() + timedelta(days=5)
               note.excludedOwners = []
               note.favedOwners = []
               note.noteProperty = postdata['noteProperty']
               note.imageURL = postdata['imageurl']
               note.pinPoint = postdata['pinPoint']
        
               newNote = note.save()
               
               doc = formNoteDict(newNote,postdata['ownerid'])
                        
               
          except Exception,e:
               self.logger.error('postNewNote_Exception')
               self.logger.error(str(e),exc_info=True)
               data = {"data" : {"error" : "Error in posting note"}}
               return data
          
          return {"data" : [doc]}
          
     
     def postImage(self,imgFilename):

        returnData = {}
        
        try:
            path = os.path.join('/tmp',imgFilename)
            
            im = Image.open(path)
            width = im.size[0]
            height = im.size[1]

            f = open(path,'r')
            imgData = f.read()
            f.close()
            
            mongouri = 'mongodb://localhost:27017'
            client = pymongo.MongoClient(mongouri)
            db = client["pinit"]
            gfs = gridfs.GridFS(db,collection='images')

            imgFileid = gfs.put(imgData, content_type='image/png',thumbnail_id=None,width=width,height=height)
            
            returnData["status"] = "success"
            returnData["image"] = str(imgFileid)
        
        except Exception, e:
            
            self.logger.error('postImage_Exception')
            self.logger.error(str(e),exc_info=True)
            
            returnData["status"] = "error"
            returnData["message"] = str(e)
            
        return returnData
          
     

class OwnerQueries():
     
     def __init__(self):
          
          self.logger = logging.getLogger(__name__)
          self.host = Configuration['mongodb']['uri']
          connect('owners',host=self.host)
          
     
     def __sendWelcomeMail(self,email,name):
          
          try:
               emailManager = EmailManager()
               emailURL = 'http://' + Configuration['EMAIL']['host'] + ':' + Configuration['EMAIL']['port'] + '/api/owner/register/confirm/' + name
               htmlBody = emailManager.generateConfirmationTemplate(emailURL)
               access_key = Configuration['AWS']['access_key']
               secret_key = Configuration['AWS']['secret_key']
               conn = boto.ses.connect_to_region('eu-west-1',aws_access_key_id=access_key,aws_secret_access_key=secret_key)
               conn.send_email(source='bharathkumar.devaraj@gmail.com',
                    subject='Welcome to NoteWall',
                    return_path='bharathkumar.devaraj@gmail.com',
                    body=None,
                    to_addresses=email,
                    html_body=htmlBody)
          except Exception, e:
               print ('Error in sending Welcome Email')
               self.logger.error('sendWelcomeMail_Exception')
               self.logger.error(str(e),exc_info=True)
               
     
     def resendConfirmationEmail(self,ownerid):
          
          
          ownername = None
          email = None
          owner = None
          
          try:
               for o in Owners.objects(id=ownerid):
                    owner = o
                    ownername = o.screenName
                    email = o.email
                    
               if owner != None:
                    d = owner.stats
                    if d['mailCount'] <= 10:
                         self.__sendWelcomeMail(email,ownername)
                         d['mailCount'] = d['mailCount'] + 1
                         owner.stats = d
                         owner.save()
                         resp = {"success":"OK"}
                    else:
                         resp = {"error" : "Quota Breached"}
               else:
                    resp = {"error":"No owner found"}
          except Exception, e:
                self.logger.error('resendConfirmationEmail_Exception')
                self.logger.error(str(e),exc_info=True)
                resp = {"error": str(e)}
                
          
          return {"data" : resp}
          
     def regitserOwner(self,email,password=None,screenname=None):
          
          isEmailAvailable = False
          resp = {}
          socialPassword = 'social:login'
          
          for owner in Owners.objects(email=email):
               isEmailAvailable = True
               ownerid = str(owner.id)
               token = authentication.generateToken(ownerid)
               ownerpassword = owner.password
               resp['ownerid'] = ownerid
               resp['screenname'] =  owner.screenName
               resp['registerstatus'] =  owner.registerStatus
               resp['token'] =  token
               resp['stats'] = owner.stats
               break
          
          if (isEmailAvailable == True and password != None):
               if checkPassword(ownerpassword,password) == False:
                    resp = {'error':'Invalid password'}
                       
          
          if (isEmailAvailable == False and screenname == None):
               if (password == None):
                    resp = {'error':'socialscreenname'}
               else:
                    resp = {'error':'Need a screen name.'}
               
          elif (isEmailAvailable == False):
               owner = Owners()
               owner.email = email
               owner.screenName = screenname.lower()
               owner.registerStatus = "AWAITING"
               owner.favorites = []
               owner.followers = []
               owner.stats = {'mailCount' : 1}
               owner.pins = {}
               if password == None:
                    owner.password = socialPassword
               else:
                    owner.password = hashPassword(password)
               owner.creationDate = datetime.now()
               owner.lastModifiedDate = datetime.now()
               try:
                    data = owner.save()
                    resp['ownerid'] =  str(data.id)
                    token = authentication.generateToken(str(data.id))
                    resp['screenname'] =  owner.screenName
                    resp['registerstatus'] =  owner.registerStatus
                    resp['token'] =  token
                    resp['stats'] = owner.stats
                    self.__sendWelcomeMail(email,resp['screenname'])
               except Exception, e:
                    if 'duplicate' in str(e):
                         resp = {"error" : "Screen Name Already Exists"}
                    else:
                         self.logger.error('registerOwner_Exception')
                         self.logger.error(str(e),exc_info=True)
                         resp = {"error" : "Unknown Error"}
          
          
          return {"data" : resp}
     
     def followOwner(self,ownerid,followingownerid):
          
          resp = {}
          validFollowingOwner = False
          followingOnwer = None
          followedOwner = None
          
          try:
               
               for f in Owners.objects(id=followingownerid):
                    validFollowingOwner = True
                    
               
               if validFollowingOwner == True:
                    if ownerid == followingownerid:
                         resp = {"error":"Cannot add to self"}
                    else:
                         for o in Owners.objects(id=followingownerid):
                              followingOnwer = o
                              
                         for fol in Owners.objects(id=ownerid):
                              followedOwner = fol
                              
                         followers = followingOnwer.followers
                         following = followedOwner.following
                         
                         if ownerid in followers:
                              followers.remove(ownerid)
                              following.remove(followingownerid)
                         else:
                              followers.append(ownerid)
                              following.append(followingownerid)
                
                         followingOnwer.followers = followers
                         followedOwner.following = following
                         
                         followingOnwer.save()
                         followedOwner.save()
               
                         resp = {"success":"OK"}
               else :
                    resp = {"error":"Not a valid follow owner id"}
          except Exception, e:
                    resp = {"error": str(e)}
                    self.logger.error('followOwner_Exception')
                    self.logger.error(str(e),exc_info=True)
          
          return {"data" : resp}
     
     
     def updateScreenName(self,ownerid,name):
          
          resp = {}
          recordFound = False
          
          try:
               for o in Owners.objects(id=ownerid):
                    o.screenName = name.lower()
                    o.save()
                    recordFound = True
               if recordFound == True:
                    resp = {"success":"OK"}
               else:
                    resp = {"error":"No owner found"}
          except Exception, e:
                self.logger.error('updateScreenName_Exception')
                self.logger.error(str(e),exc_info=True)
                resp = {"error": str(e)}
                
          
          return {"data" : resp}
     
     def updatePassword(self,ownerid,oldpassword,newpassword):
          
          resp = {}
          existingPassword = None
          owner = None
          
          for o in Owners.objects(id=ownerid):
               existingPassword = o.password
               owner = o
          
          if owner == None:
               resp = {"error" : "Given owner not found"}
          else:
               if checkPassword(existingPassword,oldpassword) == False:
                    resp = {"error" : "Wrong old password"}
               else:
                    owner.password = hashPassword(newpassword)
                    owner.save()
                    resp = {"success" : "OK"}
                    
          return {"data" : resp}
     
     
     def getDetails(self,ownerid):
          
          resp = {}
          
          for o in Owners.objects(id=ownerid):
               resp['email'] = o.email
               resp['screenname'] = o.screenName
               resp['favorites'] = o.favorites
               resp['followers'] = o.followers
               resp['following'] = o.following
               
          names = {}
          for oid in resp['followers']:
               for o in Owners.objects(id=oid):
                   names[o.screenName] = oid
     
          resp['followers'] = names
          
          
          names = {}
          for oid in resp['following']:
               for o in Owners.objects(id=oid):
                   names[o.screenName] = oid
          
          resp['following'] = names
          
               
          return {'data' : resp}
     
     def confirmRegistration(self,name):
          
          owner = None
          resp = {}
          
          for o in Owners.objects(screenName=name):
               owner = o
               
          if owner == None:
               resp = {'error' : 'Given Name not found'}
               
          else:
               currentDate = datetime.now()
               signedDate = o.creationDate
               diff = currentDate - signedDate
               if (diff.days > 1):
                    resp = {'error' : 'expired'}
               else:
                    owner.registerStatus = "CONFIRMED"
                    owner.save()
                    
                    resp['ownerid'] =  str(owner.id)
                    resp['screenname'] =  owner.screenName
                    resp['registerstatus'] =  owner.registerStatus
                    resp = {'success' : 'OK'}          
          return resp
     
     
     def getPins(self, ownerid ):
          
          owner = None
          resp = {}
          
          for o in Owners.objects(id=ownerid):
               owner = o
               
          if owner == None:
               resp = {'error' : 'Given owner id not found'}
          else:
               pindata = owner.pins
               if 'Gold' not in pindata:
                  pindata['Gold'] = 0
               if 'Silver' not in pindata:
                    pindata['Silver'] = 0
               if 'Bronze' not in pindata:
                    pindata['Bronze'] =0
                    
               resp = pindata
               
          return {'data' : resp}
     
     
     def updatePinCount(self,ownerid,pintype,pincount):
          
          owner = None
          resp = {}
          
          for o in Owners.objects(id=ownerid):
               owner = o
               
          if owner == None:
               resp = {'error' : 'Given owner id not found'}
          else:
               try:
                    pinsDict = owner.pins
                    
                    
                    if pintype in pinsDict:
                         existingCount = pinsDict[pintype]
                         newPinCount = existingCount + pincount
                    else:
                         newPinCount = pincount
                    
                    pinsDict[pintype] = newPinCount
                    owner.pins = pinsDict
                    owner.save()
               
                    resp = {'success' : 'OK'}
                    
               except Exception, e:
                    resp = {'error' : str(e)}
                    
          return {'data' : resp}
               
          
          
          
     
               
               