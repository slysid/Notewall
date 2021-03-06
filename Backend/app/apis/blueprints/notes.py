#!/usr/bin/python

from flask import Blueprint, jsonify, request, send_from_directory, redirect, url_for
from app import Configuration
import json
from app.models.queries.Queries import NoteQueries
import datetime
from werkzeug import secure_filename
import os
from app import app
from PIL import Image
from app.managers.authentication import Authentication, canRespondToRequest
from app.managers.authentication import auth
import logging


notes = Blueprint('notes',__name__)
noteQueries = NoteQueries()
authentication = Authentication()
    
def validatePostParam(data=None):
    
    response = None
    postdata = None
    ownerid = None
    
    try:
        if data == None:
            parseData = request.data
        else:
            parseData = data
        
        if type(parseData) == str:
             postdata = json.loads(parseData)
        else:
            postdata = parseData
    except:
        response = {"data" : {"error" : "Missing post body"}}
    
    try:
        ownerid = postdata['ownerid']
    except:
        response = {"data" : {"error" : "Missing ownerid"}}
    
    return (response,postdata,ownerid)


def generalLogging(logger):
        
        logger.debug('URL:')
        logger.debug(request.url)
        
        logger.debug('POST BODY:')
        logger.debug(request.data)
    
        logger.debug('HEADERS:')
        logger.debug(request.headers)



@notes.route('/poll',methods=["POST"])
def poll():
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
        response, postdata, ownerid = validatePostParam(request.json)
        logger = logging.getLogger(__name__)
        generalLogging(logger)
        
        if response != None:
            return jsonify(response)
    
        data = noteQueries.getCount(ownerid)
        return jsonify(data)
    
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})


@notes.route('/notes/all',methods=["POST"])
def allnotes():
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
        response, postdata, ownerid = validatePostParam(request.json)
        logger = logging.getLogger(__name__)
        generalLogging(logger)
    
        if response != None:
            return jsonify(response)
    
        data = noteQueries.getAllNotes(ownerid)
        return jsonify(data)
    
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})
        

@notes.route('/notes/all/owner',methods=["POST"])
def notesForOwner():
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
        response, postdata, ownerid = validatePostParam(request.json)
        logger = logging.getLogger(__name__)
        generalLogging(logger)
    
        if response != None:
            return jsonify(response)
    
        data = noteQueries.getAllNotesForOwner(ownerid)
        return jsonify(data)
    
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})
    

@notes.route('/notes/<noteid>/favorite',methods=["PUT"])
def addNotesToFavorite(noteid):
     
     authorization = canRespondToRequest()
     
     if authorization[0] == True:
        response, postdata, ownerid = validatePostParam(request.json)
        logger = logging.getLogger(__name__)
        generalLogging(logger)
    
        if response != None:
            return jsonify(response)

        data = noteQueries.addNotesToFav(noteid,ownerid)
        return jsonify(data)
    
     else:
        
        return jsonify({'data':{'error' : authorization[1]}})
    
    
@notes.route('/notes/<noteid>/remove',methods=["DELETE"])
def removeNoteForOwner(noteid):
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
        response, postdata, ownerid = validatePostParam(request.json)
        logger = logging.getLogger(__name__)
        generalLogging(logger)
    
        if response != None:
            return jsonify(response)
    
        data = noteQueries.removeNoteForOwner(noteid,ownerid)
        return jsonify(data)
    
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})


@notes.route('/notes/all/favs',methods=["POST"])
def getFavNotes():
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
        response, postdata, ownerid = validatePostParam(request.json)
        logger = logging.getLogger(__name__)
        generalLogging(logger)
    
        if response != None:
            return jsonify(response)
    
        data = noteQueries.getAllFavNotesForOwner(ownerid)
        return jsonify(data)
    
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})


@notes.route('/notes/post', methods =["POST"])
def postNewNote():
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
    
        if (request.headers['Content-Type'] == 'application/json'):
    
            response, postdata, ownerid = validatePostParam()
            logger = logging.getLogger(__name__)
            generalLogging(logger)
    
            if response != None:
                return jsonify(response)
    
            data = noteQueries.postNewNote(postdata)
            return jsonify(data)
        elif ('multipart/form-data' in request.headers['Content-Type']):
            return postImage(authorization[1])
        else:
            return jsonify({"warn":"No operation performed"})
        
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})



def postImage(oid): 
    
    try:
        logger = logging.getLogger(__name__)
        generalLogging(logger)
        
        if 'jsondata' in request.form:
            data = request.form['jsondata']
            data = json.loads(data)
        else:
            return jsonify({"error" : "Missing key - jsondata."})
    
        if len(data) == 0:
            return jsonify({"error" : "Missing postbody."})
        
        response, postdata, ownerid = validatePostParam(data)
        ownerid = oid
        
        if response != None:
            return jsonify(response)
        
        path =  app.config['UPLOAD_FOLDER']
        f = request.files['file']
    
        if f:
            filename = secure_filename(f.filename)
            f.save(os.path.join(path,filename))
            
            thumbSize = 150,150
            orgFile = os.path.join(path,filename)
            thumbFileName = 'THUMB_' + filename
            print thumbFileName
            thumbFilePath = os.path.join(path,thumbFileName)
            print thumbFilePath
            
            im = Image.open(orgFile)
            im.thumbnail(thumbSize, Image.ANTIALIAS)
            im.save(thumbFilePath, 'JPEG')
            
            
            data = noteQueries.postNewNote(postdata)
            return jsonify(data)
        else:
             return jsonify({"error" : "Not able to locate file"})
    
    except Exception, e:
        return jsonify({"error" : str(e)})
    
            

@notes.route('/uploads/<filename>',methods=['GET'])
def uploaded_file(filename):
    
    try:
        return send_from_directory(app.config['UPLOAD_FOLDER'],
                                filename)
    except Exception, e:
        return jsonify({"error" : str(e)})
    
    
@notes.route('/notes/images',methods=['GET'])
def getNotesImages():
    notes = {
        
        'free' : [
              
               ['https://s3-eu-west-1.amazonaws.com/pinitapp/free/1/noteBlue1.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/1/noteGreen1.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/1/notePink1.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/1/noteWhite1.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/1/noteYellow1.png'],
        
            ['https://s3-eu-west-1.amazonaws.com/pinitapp/free/2/noteBlue2.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/2/noteGreen2.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/2/notePink2.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/2/noteWhite2.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/2/noteYellow2.png'],
            
            ['https://s3-eu-west-1.amazonaws.com/pinitapp/free/3/noteBlue3.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/3/noteGreen3.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/3/notePink3.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/3/noteWhite3.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/3/noteYellow3.png'],
            
            ['https://s3-eu-west-1.amazonaws.com/pinitapp/free/4/noteBlue4.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/4/noteGreen4.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/4/notePink4.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/4/noteWhite4.png',
              'https://s3-eu-west-1.amazonaws.com/pinitapp/free/4/noteYellow4.png']
            ],
            
        'sponsored' : [
            
            ['https://s3-eu-west-1.amazonaws.com/pinitapp/sponsored/sponsored.png']
        ]
    }
    return jsonify({'data': {'notes':notes}})
    
