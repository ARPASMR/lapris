# -*- coding: utf-8 -*-
"""
Created on Tue Oct  2 10:07:26 2018

@author: mmussin
"""
from flask import Flask
from flask import render_template
app = Flask(__name__)

#s3=FlaskS3(app)
@app.route("/")
def hello():
    return render_template('skeleton.html')
if __name__=="__main__":
    app.run(host='0.0.0.0',port=8891,debug=True)
