#!/usr/bin/python
import sys
import logging
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0,"/var/www/FlaskApp/")
sys.path.append('/var/www/FlaskApp/FlaskApp/venv/lib/python2.7/site-packages')

from FlaskApp import app as application
application.secret_key = 'ith1nkItc4ntB3FoundBy4ny0n3'  
