#!/usr/bin/python

from mongoengine import *

class Owners(Document):
     email = EmailField(unique=True)
     screenName = StringField(unique=True)
     password = StringField()
     favorites = ListField()
     followers = ListField()
     following = ListField()
     creationDate = DateTimeField(required=True)