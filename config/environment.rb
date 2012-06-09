# Load the rails application
require File.expand_path('../application', __FILE__)

APP_VERSION = `git describe --always` unless defined? APP_VERSION
#APP_VERSION = '0.1.1'

# Initialize the rails application
Sprinter::Application.initialize!
