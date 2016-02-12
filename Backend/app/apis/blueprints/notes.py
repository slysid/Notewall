#!/usr/bin/python

from flask import Blueprint, jsonify, request
from app import Configuration
import json
from app.models.queries.Queries import NoteQueries
import datetime


notes = Blueprint('notes',__name__)
noteQueries = NoteQueries()
    

@notes.route('/notes/all',methods=["POST"])
def allnotes():
    
    try:
        if type(request.data) == str:
             postdata = json.loads(request.data)
        else:
            postdata = request.data
    except:
        data = {"data" : {"error" : "Missing post body"}}
        return jsonify(data)
    
    try:
        ownerid = postdata['ownerid']
    except:
        data = {"data" : {"error" : "Missing ownerid"}}
        return jsonify(data)
    
    data = noteQueries.getAllNotes(ownerid)
    return jsonify(data)
        

@notes.route('/notes/all/owner',methods=["POST"])
def notesForOwner():
    
    try:
        if type(request.data) == str:
             postdata = json.loads(request.data)
        else:
            postdata = request.data
    except:
        data = {"data" : {"error" : "Missing post body"}}
        return jsonify(data)
    
    try:
        ownerid = postdata['ownerid']
    except:
        data = {"data" : {"error" : "Missing ownerid"}}
        return jsonify(data)
    
    data = noteQueries.getAllNotesForOwner(ownerid)
    return jsonify(data)

@notes.route('/notes/<noteid>/favorite',methods=["PUT"])
def addNotesToFavorite(noteid):
     
     try:
        if type(request.data) == str:
             postdata = json.loads(request.data)
        else:
            postdata = request.data
     except:
        data = {"data" : {"error" : "Missing post body"}}
        return jsonify(data)
    
     try:
        ownerid = postdata['ownerid']
     except:
        data = {"data" : {"error" : "Missing ownerid"}}
        return jsonify(data)

     data = noteQueries.addNotesToFav(noteid,ownerid)
     return jsonify(data)
    
@notes.route('/notes/<noteid>/remove',methods=["DELETE"])
def removeNoteForOwner(noteid):
    
    try:
        if type(request.data) == str:
             postdata = json.loads(request.data)
        else:
            postdata = request.data
    except:
        data = {"data" : {"error" : "Missing post body"}}
        return jsonify(data)
    
    try:
        ownerid = postdata['ownerid']
    except:
        data = {"data" : {"error" : "Missing ownerid"}}
        return jsonify(data)
    
    data = noteQueries.removeNoteForOwner(noteid,ownerid)
    return jsonify(data)


@notes.route('/notes/post', methods =["POST"])
def postNewNote():
    try:
        if type(request.data) == str:
             postdata = json.loads(request.data)
        else:
            postdata = request.data
    except:
        data = {"data" : {"error" : "Missing post body"}}
        return jsonify(data)
    
    data = noteQueries.postNewNote(postdata)
    return jsonify(data)

@notes.route('/notes/all/favs',methods=["POST"])
def getFavNotes():
    
    try:
        if type(request.data) == str:
             postdata = json.loads(request.data)
        else:
            postdata = request.data
    except:
        data = {"data" : {"error" : "Missing post body"}}
        return jsonify(data)
    
    try:
        ownerid = postdata['ownerid']
    except:
        data = {"data" : {"error" : "Missing ownerid"}}
        return jsonify(data)
    
    data = noteQueries.getAllFavNotesForOwner(ownerid)
    return jsonify(data)
    
    