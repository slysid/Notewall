#!/usr/bin/python

from flask import Blueprint,request,jsonify
import json
from app.models.queries.Queries import OwnerQueries

owners = Blueprint('owner',__name__)
ownerQueries = OwnerQueries()


@owners.route('/owner/register',methods=["POST"])
def registerOwner():
    if request.method == 'POST':
         
         if type(request.data) == str:
             postdata = json.loads(request.data)
         else:
             postdata = request.data
         
         email = postdata['email']
         password = None
         if 'password' in postdata:
            password = postdata['password']
         resp = ownerQueries.regitserOwner(email,password)
         
         return jsonify(resp)
         