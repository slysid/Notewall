#!/usr/bin/python

from mongoengine import *
from app import Configuration
from app.models.Notes import Notes
from app.models.Owners import Owners
from datetime import datetime, timedelta
from time import strftime
import uuid
import hashlib


def _hashPassword(password):
    salt = uuid.uuid4().hex
    return hashlib.sha256(salt.encode() + password.encode()).hexdigest() + ':' + salt
    
def _checkPassword(hashed_password, user_password):
    password, salt = hashed_password.split(':')
    return password == hashlib.sha256(salt.encode() + user_password.encode()).hexdigest()


class NoteQueries():
     
     def __init__(self):
          
          self.host = Configuration['mongodb']['uri']
          connect('notes',host=self.host)
     
     
     def getAllNotes(self,ownerid):
          
          allNotes = []
          
          try:
          
               for note in Notes.objects(noteDeletionDate__gt=datetime.now()):
                    if ownerid not in note.excludedOwners:
                         doc = {}
                         doc['noteID'] = str(note.id)
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
                         doc = {}
                         doc['noteID'] = str(note.id)
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
                              doc = {}
                              doc['noteID'] = str(note.id)
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
               print favorites
               if noteid in favorites:
                    dataInAllList = True
                    favorites.remove(noteid)
                    owner.favorites = favorites
                    print "updated"
                    ownUpdate = True
               
               if dataInAllList == True:
                    if excludeUpdate == True and favUpdate == True and ownUpdate == True:
                         note.save()
                         owner.save()
               else:
                    if excludeUpdate == True or favUpdate == True:
                         note.save()
                         owner.save()
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
        
               newNote = note.save()
               
               doc = {}
               doc['noteID'] = str(newNote.id)
               doc['noteType'] = newNote.noteType
               doc['noteText'] = newNote.noteText
               doc['noteTextColor'] = newNote.noteTextColor
               doc['noteTextFontSize'] = newNote.noteTextFontSize
               doc['noteTextFont'] = newNote.noteTextFont
               doc['notePinned'] = newNote.notePinned
               doc['owners'] = newNote.favedOwners
               doc['exclusions'] = newNote.excludedOwners
               doc['creationDate'] = newNote.creationDate
               doc['deletionDate'] = newNote.noteDeletionDate
               
          except Exception,e:
               print str(e)
               data = {"data" : {"error" : "Error in posting note"}}
               return data
          
          return {"data" : [doc]}
          
     

class OwnerQueries():
     
     def __init__(self):
          
          self.host = Configuration['mongodb']['uri']
          connect('owners',host=self.host)
          
     def regitserOwner(self,email,password=None):
          
          isEmailAvailable = False
          resp = {}
          
          for owner in Owners.objects(email=email):
               isEmailAvailable = True
               ownerid = str(owner.id)
               ownerpassword = owner.password
               resp['ownerid'] = ownerid
               break
          
          if (isEmailAvailable == True and password != None):
               if _checkPassword(ownerpassword,password) == False:
                    resp = {'error':'Invalid password'}
                       
          
          if (isEmailAvailable == False):
               owner = Owners()
               owner.email = email
               owner.favorites = []
               if password == None:
                    owner.password = "social:login"
               else:
                    owner.password = _hashPassword(password)
               owner.creationDate = datetime.now()
               data = owner.save()
               resp['ownerid'] =  str(data.id)
          
          
          return {"data" : resp}