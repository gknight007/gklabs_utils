#!/usr/bin/python


import requests
import getopt
import sys
import json
import traceback

host = None
port = 8000
user = None
passwd = None

baseJob=''

def getJobs():
    global host
    global port
    global user
    global passwd

    jobList = []
    url='http://%s:%s/me/my-views/view/All/api/json' % (host, port)
    headers={'content-type': 'application/json'}

    if user != None and passwd != None:
        response = requests.get(url, auth=(user, passwd), headers=headers )
    else:
        response = requests.get(url, headers=headers)

    if response.status_code != 200:
        sys.stderr.write("Unable to get job list.\n\n%s\n\n" % response.text)
        exit(1)

    try:
        jobInfo = response.json()
    except Exception, err:
        sys.stderr.write(str(err))
        exit(1)

    for each in jobInfo['jobs']:
        if not 'name' in each:
            continue
        jobList.append( each['name'] )

    return jobList

def cloneJobs(origJob, newJobNameList):
    global host
    global port
    global user
    global passwd
    url = 'http://%s:%s/createItem' % (host, port)
    headers={'content-type': 'application/json'}

    existingJobList = getJobs()

    if not origJob in existingJobList:
        sys.stderr.write("ERROR: Unable to find job %s in jenkins.  Exiting!\n" % origJob)
        exit(1)

    for each in newJobNameList:
        try:
            requestKwargs = {'params': {'name': each, 'mode': 'copy', 'from': origJob}, 'headers': headers }

            if user != None and passwd != None:
                requestKwargs.update( {'auth': (user, passwd)} )

            response = requests.post(url, **requestKwargs)

            if response.status_code != 200:
                sys.stderr.write("ERROR: Unable to copy job %s to %s\n" % (origJob, each))
                sys.stderr.write("HTTP STATUS: %s\n" % response.status_code)
                sys.stderr.write(response.text)
                sys.stderr.write('\n\n')
            else:
                sys.stderr.write("Created new job %s\n" % each)
                #sys.stderr.write(response.text)

        except:
            sys.stderr.write('ERROR: while copying job %s.\n' % each)
            sys.stderr.write( traceback.format_exc()  )
            sys.stderr.write('\n\n')
            continue

def usage():
    sys.stderr.write("Usage: %s -h <jenkins_host> -o <original_job> -n <new_job> [-n <new_job> ] [-u <jenkins_user> ] " % sys.argv[0])
    sys.stderr.write("[ -w <jenkins_password> ] [ -p <jenkins_port> ]\n")

def main():
    global host
    global port
    global user
    global passwd

    newNameList=[]
    origJobName = None

    try:
        opts, args = getopt.getopt(sys.argv[1:], 'o:n:h:p:w:u:', ['--user', '--pass', '--host', '--port', '--orig', '--new'])

    except getopt.GetoptError , err:
        sys.stderr.write(err)
        exit(1)

    for o, a in opts:
        if o in ['-o', '--orig']:
            origJobName = a
        elif o in ['-h', '--host']:
            host = a
        elif o in ['-p', '--port']:
            port = a
        elif o in ['-n', '--new']:
            newNameList.append(a)
        elif o in ['-u', '--user']:
            user = a
        elif o in ['-w', '--pass']:
            passwd = a

    if host == None or len(newNameList) == 0 or origJobName == None:
        usage()
        exit(1)

    cloneJobs(origJobName, newNameList)


if __name__ == '__main__':
    main()


