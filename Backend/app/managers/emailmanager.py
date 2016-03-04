#!/usr/bin/python

import jinja2

class EmailManager():
    
    def generateConfirmationTemplate(self,confirmURL):
        env = jinja2.Environment(loader=jinja2.PackageLoader('app', 'templates'))
        template = env.get_template('register.html')
        return template.render(confirmationURL=confirmURL)