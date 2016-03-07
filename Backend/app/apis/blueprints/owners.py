#!/usr/bin/python

from flask import Blueprint,request,jsonify,render_template
import json
from app.models.queries.Queries import OwnerQueries
from app.managers.authentication import auth
from app.managers.authentication import Authentication, canRespondToRequest

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
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
        
        ownerid = authorization[1]
        
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
        
    else:
        return jsonify({'data':{'error' : authorization[1]}})
        

    
@owners.route('/owner/update/screenname',methods=["PUT"])
def updateScreenName():
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
    
        if request.method == 'PUT':
            
            ownerid = authorization[1]
            
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
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})
    

@owners.route('/owner/update/password',methods=["PUT"])
def updatePassword():
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
    
        if request.method == 'PUT':
            
            ownerid = authorization[1]
            
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
        
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})
    


@owners.route('/owner/details',methods=["POST"])
def getOwnerDetails():
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
    
        if request.method == 'POST':
            
            ownerid = authorization[1]
            
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
        
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})
    
    
@owners.route('/owner/register/confirm/<name>',methods=["GET"])
def confirmRegistration(name):
    
    if request.method == 'GET':
            
        resp = ownerQueries.confirmRegistration(name.lower())
        if 'error' in resp:
            return render_template('error.html')
        return render_template('confirm.html')