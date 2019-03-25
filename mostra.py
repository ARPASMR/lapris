# -*- coding: utf-8 -*-
"""
Created on Tue Oct  2 10:07:26 2018

@author: mmussin
"""
from flask import Flask
from flask import render_template,url_for,request,redirect
app = Flask(__name__)

#s3=FlaskS3(app)
@app.route("/")
def hello():
    return render_template('skeleton.html')
@app.route("/form/", methods=['GET', 'POST'])
def form():
    if request.method == 'POST':
        glon = request.form['glon']
        ore=request.form['ore']
        shapefile=request.form['shapefile']
        label=request.form['label']
        #glat = request.form['glat']
        stringa=glon+" "+ore+" "+shapefile+" "+label
        execute_bash(stringa)
        return "eseguito!"
    return render_template('form.html')
def execute_bash(file):
    import subprocess
    cmd='./recupero.sh '+file
    try:
        subprocess.run (["./recupero.sh",file])
    except:
        print('Something went wrong with recupero.sh')
    return   
if __name__=="__main__":
    app.run(host='0.0.0.0',port=8891,debug=True)
