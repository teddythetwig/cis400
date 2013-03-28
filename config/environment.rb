# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
CIS400::Application.initialize!

ENV['JAVA_HOME'] = "/usr/lib/jvm/java-7-oracle/"

