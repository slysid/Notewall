#!/usr/bin/python

from app import app
from app import Configuration

if __name__ == '__main__':
     if Configuration['GENERAL']['debug'] == 'true':
          app.run(host='0.0.0.0',debug=True)
     else:
          app.run(host='0.0.0.0')
     
