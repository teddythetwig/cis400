require 'aws'

include AWS
config_path = File.expand_path(File.dirname(__FILE__)+"/../aws.yml")
AWS.config(YAML.load(File.read(config_path)))
#this will create a global client that will allow us to skip the client initialization steps
$RDS = AWS::RDS::Client.new
