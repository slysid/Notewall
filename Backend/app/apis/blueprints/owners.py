#!/usr/bin/python

from flask import Blueprint,request,jsonify,render_template
import json
from app.models.queries.Queries import OwnerQueries
from app.managers.authentication import auth
from app.managers.authentication import Authentication, canRespondToRequest
import logging

owners = Blueprint('owner',__name__)
ownerQueries = OwnerQueries()


def generalLogging(logger):
        
        logger.debug('URL:')
        logger.debug(request.url)
        
        if request.method != 'GET': 
            logger.debug('POST BODY:')
            logger.debug(request.data)
    
        logger.debug('HEADERS:')
        logger.debug(request.headers)


@owners.route('/owner/register',methods=["POST"])
def registerOwner():
    
    if request.method == 'POST':
         
         logger = logging.getLogger(__name__)
         generalLogging(logger)
         
         try:
            if type(request.data) == str:
                postdata = json.loads(request.data)
            else:
                postdata = request.data
         except Exception, e:
              logger.error('Exception Raised')
              logger.error(str(e))
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
        
        if request.method == 'PUT':
            
            logger = logging.getLogger(__name__)
            generalLogging(logger)
            
            try:
                if type(request.data) == str:
                    postdata = json.loads(request.data)
                else:
                    postdata = request.data
            except Exception, e:
                logger.error('Exception Raised')
                logger.error(str(e))
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
            
            logger = logging.getLogger(__name__)
            generalLogging(logger)
            
            try:
                if type(request.data) == str:
                    postdata = json.loads(request.data)
                else:
                    postdata = request.data
            except Exception, e:
                logger.error('Exception Raised')
                logger.error(str(e))
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
            
            logger = logging.getLogger(__name__)
            generalLogging(logger)
            
            try:
                if type(request.data) == str:
                    postdata = json.loads(request.data)
                else:
                    postdata = request.data
            except Exception, e:
                logger.error('Exception Raised')
                logger.error(str(e))
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
            
            logger = logging.getLogger(__name__)
            generalLogging(logger)
            
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
        
        logger = logging.getLogger(__name__)
        generalLogging(logger)
            
        resp = ownerQueries.confirmRegistration(name.lower())
        if 'error' in resp:
            return render_template('error.html')
        return render_template('confirm.html')
    
    
@owners.route('/owner/resend',methods=['POST'])
def resendConfirmationMail():
    
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
        logger = logging.getLogger(__name__)
        generalLogging(logger)
    
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
        
        return jsonify(ownerQueries.resendConfirmationEmail(postdata['ownerid']))
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})
    
    
    
@owners.route('/owner/getpins',methods=['POST'])
def getPinsForOwner():
    
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
        logger = logging.getLogger(__name__)
        generalLogging(logger)
    
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
        
        return jsonify(ownerQueries.getPins(postdata['ownerid']))
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})
    
    
    
@owners.route('/owner/pins/update',methods=["POST"])
def updatePinCount():
    
    authorization = canRespondToRequest()
    
    if authorization[0] == True:
        logger = logging.getLogger(__name__)
        generalLogging(logger)
    
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
        
        if 'type' not in postdata:
            response = {'data' : {'error' : 'Missing pin type'}}
            return jsonify(response)
        
        if 'count' not in postdata:
            response = {'data' : {'error' : 'Missing pin type count'}}
            return jsonify(response)
        
        return jsonify(ownerQueries.updatePinCount(postdata['ownerid'],postdata['type'],postdata['count']))
    else:
        
        return jsonify({'data':{'error' : authorization[1]}})
    
    
    
@owners.route('/pins/products', methods=["GET"])
def getPinProducts():
    
    return jsonify({'data' : {'BronzeID':20,'SilverID':20,'GoldID':20}})

    