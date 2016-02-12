#!/usr/bin/python

from mongoengine import *

class Owners(Document):
     email = EmailField(unique=True)
     password = StringField()
     favorites = ListField()
     creationDate = DateTimeField(required=True)