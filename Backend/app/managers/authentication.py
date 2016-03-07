#!/usr/bin/python

from flask.ext.httpauth import HTTPBasicAuth
from itsdangerous import (TimedJSONWebSignatureSerializer
                          as Serializer, BadSignature, SignatureExpired)
from app import Configuration
import uuid
import hashlib
from app.models.Owners import Owners
from flask import request
from app import Configuration

auth = HTTPBasicAuth()

class Authentication():
    
    def __init__(self):
        self.auth = HTTPBasicAuth()
    
    def generateToken(self,username):
        s = Serializer(Configuration['AUTH']['secret_key'])
        return s.dumps({'id':username})
    
    @staticmethod
    def verify_auth_token(token):
        s = Serializer(Configuration['AUTH']['secret_key'])
        try:
            data = s.loads(token)
            print data
        except SignatureExpired:
            return None
        except BadSignature:
            return None
        
        oid = data['id']
        did = None
        
        for owner in Owners.objects(id=oid):
            did = str(owner.id)
            
        return did
    
    
@auth.verify_password
def verifyPassword(username,password):
        print username
        return True
    
def hashPassword(password):
    salt = uuid.uuid4().hex
    return hashlib.sha256(salt.encode() + password.encode()).hexdigest() + ':' + salt
    
def checkPassword(hashed_password, user_password):
    password, salt = hashed_password.split(':')
    return password == hashlib.sha256(salt.encode() + user_password.encode()).hexdigest()

def canRespondToRequest():
    
    if Configuration['GENERAL']['debug'] == 'true':
        return [True,'Debug Mode']
    else:
        try:
            print request.headers
            a = Authentication()
            token = request.headers.get('Authorization').split(':')[0]
            did = a.verify_auth_token(token)
            if did != None:
                return [True,did]
            return [False,'Access Denied. Invalid user token']
        except:
            return [False,'No Authorizationheader.Access Denied']
    