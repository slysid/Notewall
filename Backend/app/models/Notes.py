#!/usr/bin/python

from mongoengine import *
from Owners import Owners

class Notes(Document):
     
     properties = {
          
          "N" : "note",
          "P" : "polaroid"
     }
     
     ownerId = ReferenceField(Owners,required=True)
     noteType = StringField(required=True)
     noteText = StringField(required=True)
     noteTextColor = ListField(required=True)
     noteTextFontSize = FloatField(required=True)
     noteTextFont = StringField(required=True)
     notePinned = BooleanField(required=True)
     noteDeletionDate = DateTimeField(required=True)
     creationDate = DateTimeField(required=True)
     favedOwners = ListField()
     excludedOwners = ListField()
     noteProperty =  StringField(required=True,max_length=1,choices=properties.keys())
     imageURL = StringField()