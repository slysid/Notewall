#!/usr/bin/python

from mongoengine import *
from app import Configuration
from app.models.Notes import Notes
from app.models.Owners import Owners
from datetime import datetime, timedelta
from time import strftime
import uuid
import hashlib
from PIL import Image
import gridfs
import os
import pymongo


def _hashPassword(password):
    salt = uuid.uuid4().hex
    return hashlib.sha256(salt.encode() + password.encode()).hexdigest() + ':' + salt
    
def _checkPassword(hashed_password, user_password):
    password, salt = hashed_password.split(':')
    return password == hashlib.sha256(salt.encode() + user_password.encode()).hexdigest()

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
     
     for o in Owners.objects(id=doc['ownerID']):
          doc['screenName'] = o.screenName
          if ownerid in o.followers:
               doc['followingNoteOwner'] = True
          else:
               doc['followingNoteOwner'] = False
     
     return doc
     


class NoteQueries():
     
     def __init__(self):
          
          self.host = Configuration['mongodb']['uri']
          connect('notes',host=self.host)
     
     
     def getAllNotes(self,ownerid):
          
          allNotes = []
          
          try:
          
               for note in Notes.objects(noteDeletionDate__gt=datetime.now()):
                    if ownerid not in note.excludedOwners:
                         doc = formNoteDict(note,ownerid)
                         allNotes.append(doc)
          except Exception, e:
               print str(e)
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
               print str(e)
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
               print str(e)
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
               print str(e)
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
               print str(e)
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
               note.noteDeletionDate = datetime.now() + timedelta(days=3)
               note.excludedOwners = []
               note.favedOwners = []
               note.noteProperty = postdata['noteProperty']
               note.imageURL = postdata['imageurl']
        
               newNote = note.save()
               
               doc = formNoteDict(newNote,postdata['ownerid'])
                        
               
          except Exception,e:
               print str(e)
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
            
            returnData["status"] = "error"
            returnData["message"] = str(e)
            
        return returnData
          
     

class OwnerQueries():
     
     def __init__(self):
          
          self.host = Configuration['mongodb']['uri']
          connect('owners',host=self.host)
          
     def regitserOwner(self,email,password=None,screenname=None):
          
          isEmailAvailable = False
          resp = {}
          socialPassword = 'social:login'
          
          for owner in Owners.objects(email=email):
               isEmailAvailable = True
               ownerid = str(owner.id)
               ownerpassword = owner.password
               resp['ownerid'] = ownerid
               break
          
          if (isEmailAvailable == True and password != None):
               if _checkPassword(ownerpassword,password) == False:
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
               owner.favorites = []
               owner.followers = []
               if password == None:
                    owner.password = socialPassword
               else:
                    owner.password = _hashPassword(password)
               owner.creationDate = datetime.now()
               try:
                    data = owner.save()
                    resp['ownerid'] =  str(data.id)
               except Exception, e:
                    if 'duplicate' in str(e):
                         resp = {"error" : "Screen Name Already Exists"}
                    else:
                         resp = {"error" : "Unknown Error"}
          
          
          return {"data" : resp}
     
     def followOwner(self,ownerid,followingownerid):
          
          resp = {}
          validFollowingOwner = False
          
          try:
               
               for f in Owners.objects(id=followingownerid):
                    validFollowingOwner = True
                    
               
               if validFollowingOwner == True:
                    if ownerid == followingownerid:
                         resp = {"error":"Cannot add to self"}
                    else:
                         for o in Owners.objects(id=followingownerid):
                              followers = o.followers
                              if ownerid in followers:
                                   followers.remove(ownerid)
                              else:
                                   followers.append(ownerid)
                
                              o.followers = followers
                         o.save()
               
                         resp = {"success":"OK"}
               else :
                    resp = {"error":"Not a valid follow owner id"}
          except Exception, e:
                    resp = {"error": str(e)}
          
          return {"data" : resp}          