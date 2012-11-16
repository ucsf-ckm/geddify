# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Geddify::Application.initialize!

APP_CONFIG = YAML.load_file("#{Rails.root}/config/ftp.yml")[Rails.env]
GEDI_CONFIG = YAML.load_file("#{Rails.root}/config/gedi.yml")[Rails.env]


