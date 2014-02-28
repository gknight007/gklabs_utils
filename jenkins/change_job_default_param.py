#!/usr/bin/python



import requests
import getopt
import sys
import traceback
from xml.etree import ElementTree


host='localhost'
port=8000
user=None
passwd=None


getConfigUrl = lambda host, port, jobName: "http://" + host + ":" + str(port) + "/job/" + jobName + "/config.xml"

def getConfigXml(jobName):
    global user
    global passwd
    global host
    global port 
    url = getConfigUrl(host, port, jobName)
    if user != None and passwd != None:
        response = requests.get(url, auth=(user, passwd))
    else:
        response = requests.get(url)
    if response.status_code != 200:
        sys.stderr.write("ERROR: Unable to get the config.xml for the job to be modified.\n")
        sys.stderr.write(response.text)
        sys.stderr.write("\n\n")
        exit(1)
    return response.text


def usage():
    sys.stderr.write("Usage: %s -j <job_name> -k <param_name> -v <param_value> ")
    sys.stderr.write("[-h <jenkins_host>] [-p <jenkins_port>] [-u <jenkins_user>] ")
    sys.stderr.write("[-w <jenkins_password>]\n")

def updateConfig(jobName, paramName, paramValue):
    global user
    global passwd
    global host
    global port
    configXmlText = getConfigXml(jobName)
    configXmlTree = ElementTree.fromstring(configXmlText)
    for element in configXmlTree.findall('.//parameterDefinitions/hudson.model.StringParameterDefinition'):
        if element.find('name').text == paramName:
            defaultValueElement = element.find('defaultValue')
            defaultValueElement.text = paramValue

    updatedConfigXml = ElementTree.tostring(configXmlTree)
    updatedConfigXml = "<?xml version='1.0' encoding='UTF-8'?>\n" + updatedConfigXml


    url = getConfigUrl(host, port, jobName)

    if user != None and passwd != None:
        response = requests.post(url, auth=(user, passwd), data=updatedConfigXml)
    else:
        response = requests.post(url, data=updatedConfigXml)

    if response.status_code != 200:
        sys.stderr.write("ERROR: Failed to update config.xml for the job to be modified.\n")
        sys.stderr.write(response.text)
        sys.stderr.write("\n\n")
        sys.stderr.write(updatedConfigXml)
        exit(1)

def main():
    global user
    global passwd
    global host
    global port
    jobName, paramName, paramValue = None, None, None

    try:
        opts, args = getopt.getopt(sys.argv[1:], 'u:w:h:p:j:k:v:', [])
    except getopt.GetopError, err:
        usage()
        sys.stderr.write( traceback.format_exc() )
        exit(1)

    for o, a in opts:
        if o in ['-u']:
            user = a
        elif o in ['-w']:
            passwd = a
        elif o in ['-h']:
            host = a
        elif o in ['-p']:
            port = a
        elif o in ['-j']:
            jobName = a
        elif o in ['-k']:
             paramName = a
        elif o in ['-v']:
            paramValue = a


    if jobName == None or paramName == None or paramValue == None:
        usage()
        exit(1)
    updateConfig(jobName, paramName, paramValue)

if __name__ == '__main__':
    main()



