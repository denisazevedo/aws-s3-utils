import boto3
from botocore.client import Config
from datetime import datetime

# return file name with input as prefix and date and time as suffix
def get_key(name_prefix, extension):
    now = datetime.now()
    current_time = now.strftime('%Y%m%d-%H%M%S.%f')
    # print('Current Time:', current_time)
    return name_prefix + '-' + current_time + '.' + extension


s3 = boto3.client('s3')

s3 = boto3.client(
  's3',
  aws_access_key_id='<aws_access_key_id>',
  aws_secret_access_key='<aws_secret_access_key>',
  config=Config(signature_version='s3v4')
)

# TODO
# bucket = input("Enter your Bucket Name: ")
# key = input("Enter your desired filename/key for this upload: ")
bucket = 'btg-poc-cnab'

# key = 'upload-' + current_time + '.txt'
key = get_key('upload', 'txt')
# print(" Generating pre-signed url for file " + key + "...")

print(s3.generate_presigned_url('put_object', Params={'Bucket':bucket,'Key':key}, ExpiresIn=3600, HttpMethod='PUT'))
