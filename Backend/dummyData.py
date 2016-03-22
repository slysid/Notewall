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
    
    for i in range(0,2):
        email = id_generator() + '@a.com'
        name = id_generator()
        owner = Owners(email=email,
                       screenName=name,
                       password="social:login",
                       registerStatus="CONFIRMED",
                       favorites=[],
                       followers=[],
                       following=[],
                       stats = {'mailCount' : 1},
                       pins = {},
                       creationDate = datetime.datetime.now(),
                       lastModifiedDate = datetime.datetime.now()).save()
        allOwners.append(owner)
    

def __createNotes():
    
    maxInt = len(allOwners) - 1
    noteTypes = ["noteBlue1.png","noteGreen2.png","notePink3.png","noteYellow4.png"]
    
    for i in range(0,20):
        randomNoteIndex = random.randint(0,len(noteTypes) - 1)
        index = random.randint(0,maxInt)
        randomOwner = allOwners[index]
        
        xPoint  = random.randint(150,350)
        yPoint  = random.randint(150,350)
        
        note = Notes(ownerId=randomOwner,
                     noteType=noteTypes[randomNoteIndex],
                     noteText="My Note " + str(i),
                     noteTextColor=[255.0,0.0,0.0],
                     noteTextFontSize=30.0,
                     noteTextFont="Chalkduster",
                     notePinned=False,
                     creationDate = datetime.datetime.now(),
                     noteDeletionDate = datetime.datetime.now() + datetime.timedelta(days=3),
                     favedOwners = [],
                     excludedOwners = [],
                     noteProperty =  "N",
                     imageURL = "",
                     pinPoint = [xPoint,yPoint]
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
    