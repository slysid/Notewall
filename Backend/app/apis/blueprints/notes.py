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


notes = Blueprint('notes',__name__)
noteQueries = NoteQueries()
    
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

@notes.route('/poll',methods=["POST"])
def poll():
    response, postdata, ownerid = validatePostParam(request.json)
    if response != None:
        return jsonify(response)
    
    data = noteQueries.getCount(ownerid)
    return jsonify(data)


@notes.route('/notes/all',methods=["POST"])
def allnotes():
    
    response, postdata, ownerid = validatePostParam(request.json)
    
    if response != None:
        return jsonify(response)
    
    data = noteQueries.getAllNotes(ownerid)
    return jsonify(data)
        

@notes.route('/notes/all/owner',methods=["POST"])
def notesForOwner():
    
    response, postdata, ownerid = validatePostParam(request.json)
    
    if response != None:
        return jsonify(response)
    
    data = noteQueries.getAllNotesForOwner(ownerid)
    return jsonify(data)

@notes.route('/notes/<noteid>/favorite',methods=["PUT"])
def addNotesToFavorite(noteid):
     
     response, postdata, ownerid = validatePostParam(request.json)
    
     if response != None:
        return jsonify(response)

     data = noteQueries.addNotesToFav(noteid,ownerid)
     return jsonify(data)
    
    
@notes.route('/notes/<noteid>/remove',methods=["DELETE"])
def removeNoteForOwner(noteid):
    
    response, postdata, ownerid = validatePostParam(request.json)
    
    if response != None:
        return jsonify(response)
    
    data = noteQueries.removeNoteForOwner(noteid,ownerid)
    return jsonify(data)


@notes.route('/notes/all/favs',methods=["POST"])
def getFavNotes():
    
    response, postdata, ownerid = validatePostParam(request.json)
    
    if response != None:
        return jsonify(response)
    
    data = noteQueries.getAllFavNotesForOwner(ownerid)
    return jsonify(data)


@notes.route('/notes/post', methods =["POST"])
def postNewNote():
    
    if (request.headers['Content-Type'] == 'application/json'):
    
        response, postdata, ownerid = validatePostParam()
    
        if response != None:
            return jsonify(response)
    
        data = noteQueries.postNewNote(postdata)
        return jsonify(data)
    elif ('multipart/form-data' in request.headers['Content-Type']):
        return postImage()
    else:
        return jsonify({"warn":"No operation performed"})

def postImage(): 
    
    try:
        if 'jsondata' in request.form:
            data = request.form['jsondata']
            data = json.loads(data)
        else:
            return jsonify({"error" : "Missing key - jsondata."})
    
        if len(data) == 0:
            return jsonify({"error" : "Missing postbody."})
        
        response, postdata, ownerid = validatePostParam(data)
        
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
    
            

@notes.route('/uploads/<filename>')
def uploaded_file(filename):
    
    try:
        return send_from_directory(app.config['UPLOAD_FOLDER'],
                                filename)
    except Exception, e:
        return jsonify({"error" : str(e)})
    