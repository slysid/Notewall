#!/usr/bin/python


from app.models.Owners import Owners
from app.models.Notes import Notes
from mongoengine import *
import datetime
import string
import random

allOwners = []

def id_generator(size=6, chars=string.ascii_uppercase + string.digits):
     return ''.join(random.choice(chars) for _ in range(size))

def __createOwners():
    
    for i in range(0,5):
        email = id_generator() + '@a.com' 
        owner = Owners(email=email, password="social:login",favorites=[],creationDate = datetime.datetime.now()).save()
        allOwners.append(owner)
    

def __createNotes():
    
    maxInt = len(allOwners) - 1
    noteTypes = ["noteBlue1.png","noteGreen2.png","notePink3.png","noteYellow4.png"]
    
    for i in range(0,5):
        randomNoteIndex = random.randint(0,len(noteTypes) - 1)
        index = random.randint(0,maxInt)
        randomOwner = allOwners[index]
        
        note = Notes(ownerId=randomOwner,
                     noteType=noteTypes[randomNoteIndex],
                     noteText="My Note 1",
                     noteTextColor=[255.0,0.0,0.0],
                     noteTextFontSize=30.0,
                     noteTextFont="Chalkduster",
                     notePinned=False,
                     creationDate = datetime.datetime.now(),
                     noteDeletionDate = datetime.datetime.now() + datetime.timedelta(days=3),
                     favedOwners = []
        ).save()


def dropAllCollections():
    
    Owners.drop_collection()
    Notes.drop_collection()
    

def createDummyData():
    
    __createOwners()
    __createNotes()
    
    
if __name__ == '__main__':
    
    connect('pinit')
    dropAllCollections()
    createDummyData()
    