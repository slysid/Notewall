#!/usr/bin/python

from mongoengine import *

class Owners(Document):
     email = EmailField(unique=True)
     screenName = StringField(unique=True)
     registerStatus = StringField()
     password = StringField()
     favorites = ListField()
     followers = ListField()
     following = ListField()
     sponsoredNotes = ListField()
     stats = DictField()
     pins = DictField()
     creationDate = DateTimeField(required=True)
     lastModifiedDate = DateTimeField(required=True)