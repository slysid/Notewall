#!/usr/bin/python

from flask import Blueprint, jsonify, request
from app import Configuration
import json
from app.models.queries.Queries import NoteQueries
import datetime


notes = Blueprint('notes',__name__)
noteQueries = NoteQueries()
    
def validatePostParam():
    
    response = None
    postdata = None
    ownerid = None
    
    try:
        if type(request.data) == str:
             postdata = json.loads(request.data)
        else:
            postdata = request.data
    except:
        response = {"data" : {"error" : "Missing post body"}}
    
    try:
        ownerid = postdata['ownerid']
    except:
        response = {"data" : {"error" : "Missing ownerid"}}
    
    return (response,postdata,ownerid)

@notes.route('/notes/all',methods=["POST"])
def allnotes():
    
    response, postdata, ownerid = validatePostParam()
    
    if response != None:
        return jsonify(response)
    
    data = noteQueries.getAllNotes(ownerid)
    return jsonify(data)
        

@notes.route('/notes/all/owner',methods=["POST"])
def notesForOwner():
    
    response, postdata, ownerid = validatePostParam()
    
    if response != None:
        return jsonify(response)
    
    data = noteQueries.getAllNotesForOwner(ownerid)
    return jsonify(data)

@notes.route('/notes/<noteid>/favorite',methods=["PUT"])
def addNotesToFavorite(noteid):
     
     response, postdata, ownerid = validatePostParam()
    
     if response != None:
        return jsonify(response)

     data = noteQueries.addNotesToFav(noteid,ownerid)
     return jsonify(data)
    
@notes.route('/notes/<noteid>/remove',methods=["DELETE"])
def removeNoteForOwner(noteid):
    
    response, postdata, ownerid = validatePostParam()
    
    if response != None:
        return jsonify(response)
    
    data = noteQueries.removeNoteForOwner(noteid,ownerid)
    return jsonify(data)


@notes.route('/notes/post', methods =["POST"])
def postNewNote():
    
    response, postdata, ownerid = validatePostParam()
    
    if response != None:
        return jsonify(response)
    
    data = noteQueries.postNewNote(postdata)
    return jsonify(data)

@notes.route('/notes/all/favs',methods=["POST"])
def getFavNotes():
    
    response, postdata, ownerid = validatePostParam()
    
    if response != None:
        return jsonify(response)
    
    data = noteQueries.getAllFavNotesForOwner(ownerid)
    return jsonify(data)
    
    