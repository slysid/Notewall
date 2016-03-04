#!/usr/bin/python


from flask import Flask
import os
import yaml

app = Flask(__name__)

uploadPath = os.path.join(os.path.dirname(__file__),'uploads')
app.config['UPLOAD_FOLDER'] = uploadPath
app.config['ALLOWED_EXTENSIONS'] = set(['png','jpeg','jpg'])
app.config['SES_AWS_ACCESS_KEY'] = 'AKIAJBUAI5VGYYHUJZOA'
app.config['SES_AWS_SECRET_KEY'] = 'Am+EdlFoxgikqmqVtr6IA/GCiV+IX/Z6kKGsBxUWjaSq'
app.config['SES_REGION'] = 'email-smtp.eu-west-1.amazonaws.com'
app.config['SES_SENDER'] = 'bharathkumar.devaraj@gmail.com'
app.config['SES_REPLY_TO'] = 'bharathkumar.devaraj@gmail.com'


Configuration = {}
configFilePath = os.getcwd() +  '/app/config/configuration.yaml'
with open(configFilePath, 'r') as stream:
    Configuration.update(yaml.load(stream))

from apis.blueprints.owners import owners
from apis.blueprints.notes import notes
from apis.blueprints.stats import stats

app.register_blueprint(owners, url_prefix='/api')
app.register_blueprint(notes, url_prefix='/api')
app.register_blueprint(stats, url_prefix='/api')