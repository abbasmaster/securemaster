import json
import os
import sys
import requests
#import helpers
import argparse


# def testHash(hashVar):        
#     url = "https://api.echotrail.io/insights/" + hashVar
#     header = {"x-api-key": "I7TXsJcq6p2TVwxnsFKcO5rflwLlhjewarRkUPq7"}
#     response = requests.request('GET', url=url, headers=header)
#     return response.json()

#print(testHash("438b6ccd84f4dd32d9684ed7d58fd7d1e5a75fe3f3d12ab6c788e6bb0ffad5e7"))


def checkConfigRequirements(conf):
    if "api_key" not in conf:
        sys.exit(126)
    else:
        return True
    
def sendReq(conf, meta, observ_value):        
    url = conf['base_url'] + observ_value
    #need to account for pro version?
    headers = {'x-api-key': conf['api_key']}
    response = requests.request('GET', url=url, headers=headers)
    return response.json()

