# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Whenever::Application.initialize!

Whenever::Application.configure do

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
      :address  => ENV['EMAIL_SERVER'],
      :port  => ENV['EMAIL_PORT'],
      :domain => ENV['EMAIL_DOMAIN'],
      :user_name  => ENV['EMAIL_USERNAME'],
      :password  => ENV['EMAIL_PASSWORD'],
      :authentication  => :login,
      :enable_starttls_auto => true
  }

end
