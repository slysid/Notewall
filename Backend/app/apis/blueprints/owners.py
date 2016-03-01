#!/usr/bin/python

from flask import Blueprint,request,jsonify
import json
from app.models.queries.Queries import OwnerQueries

owners = Blueprint('owner',__name__)
ownerQueries = OwnerQueries()


@owners.route('/owner/register',methods=["POST"])
def registerOwner():
    if request.method == 'POST':
         
         try:
            if type(request.data) == str:
                postdata = json.loads(request.data)
            else:
                postdata = request.data
         except Exception, e:
              response = {'data' : {'error' : 'Missing post body'}}
              return jsonify(response)
             
         
         if 'email' not in postdata:
            resp = {'data' : {'error' : 'Email is mandatory'}}
            return jsonify(resp)
         
         email = postdata['email']
         password = None
         screenname = None
         
         if 'screenname' in postdata:
             screenname = postdata['screenname']
         if 'password' in postdata:
            password = postdata['password']
         resp = ownerQueries.regitserOwner(email,password,screenname)
         
         return jsonify(resp)
        
        
@owners.route('/owner/follow/<followingid>',methods=["PUT"])
def followOwner(followingid):
    if request.method == 'PUT':
         
        try:
            if type(request.data) == str:
                postdata = json.loads(request.data)
            else:
                postdata = request.data
        except Exception, e:
              response = {'data' : {'error' : 'Missing post body'}}
              return jsonify(response)
         
        if 'ownerid' not in postdata:
             response = {'data' : {'error' : 'Missing owner id'}}
             return jsonify(response)
            
        resp = ownerQueries.followOwner(postdata['ownerid'],followingid)
        return jsonify(resp)
    
@owners.route('/owner/update/screenname',methods=["PUT"])
def updateScreenName():
    if request.method == 'PUT':
         
        try:
            if type(request.data) == str:
                postdata = json.loads(request.data)
            else:
                postdata = request.data
        except Exception, e:
              response = {'data' : {'error' : 'Missing post body'}}
              return jsonify(response)
         
        if 'ownerid' not in postdata:
             response = {'data' : {'error' : 'Missing owner id'}}
             return jsonify(response)
            
        if 'screenname' not in postdata:
             response = {'data' : {'error' : 'Missing screenname'}}
             return jsonify(response)
        
        screenName =  postdata['screenname']   
        resp = ownerQueries.updateScreenName(postdata['ownerid'],screenName.lower())
        return jsonify(resp)
    

@owners.route('/owner/update/password',methods=["PUT"])
def updatePassword():
    
    if request.method == 'PUT':
        
        try:
            if type(request.data) == str:
                postdata = json.loads(request.data)
            else:
                postdata = request.data
        except Exception, e:
              response = {'data' : {'error' : 'Missing post body'}}
              return jsonify(response)
            
            
        if 'ownerid' not in postdata:
             response = {'data' : {'error' : 'Missing owner id'}}
             return jsonify(response)
            
        if 'oldpassword' not in postdata:
             response = {'data' : {'error' : 'Missing oldpassword'}}
             return jsonify(response)
            
        if 'newpassword' not in postdata:
             response = {'data' : {'error' : 'Missing newpassword'}}
             return jsonify(response)
        
        oldPass = postdata['oldpassword'] 
        newPass = postdata['newpassword']    
        
        if oldPass.lower() == newPass.lower():
             response = {'data' : {'error' : 'New password cannot be same as old password'}}
             return jsonify(response)
            
        resp = ownerQueries.updatePassword(postdata['ownerid'],oldPass,newPass)
        return jsonify(resp)
    
@owners.route('/owner/details',methods=["POST"])
def getOwnerDetails():
    
    if request.method == 'POST':
        
        try:
            if type(request.data) == str:
                postdata = json.loads(request.data)
            else:
                postdata = request.data
        except Exception, e:
              response = {'data' : {'error' : 'Missing post body'}}
              return jsonify(response)
            
            
        if 'ownerid' not in postdata:
             response = {'data' : {'error' : 'Missing owner id'}}
             return jsonify(response)
            
        resp = ownerQueries.getDetails(postdata['ownerid'])
        return jsonify(resp)
