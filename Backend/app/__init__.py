#!/usr/bin/python


from flask import Flask
import os
import yaml
import logging.config

def setupLogging():
    logFilePath = os.getcwd() +  '/app/config/logging.yaml'
    with open(logFilePath, 'r') as stream:
          logConfig = yaml.load(stream)
    logging.config.dictConfig(logConfig)

app = Flask(__name__)

uploadPath = os.path.join(os.path.dirname(os.path.abspath(__file__)),'uploads')
app.config['UPLOAD_FOLDER'] = uploadPath 
app.config['ALLOWED_EXTENSIONS'] = set(['png','jpeg','jpg'])


Configuration = {}
configFilePath = os.getcwd() +  '/app/config/configuration.yaml'
with open(configFilePath, 'r') as stream:
    Configuration.update(yaml.load(stream))
    
setupLogging()


from apis.blueprints.owners import owners
from apis.blueprints.notes import notes
from apis.blueprints.stats import stats

app.register_blueprint(owners, url_prefix='/api')
app.register_blueprint(notes, url_prefix='/api')
app.register_blueprint(stats, url_prefix='/api')