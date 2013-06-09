# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Whenever::Application.initialize!

Whenever::Application.configure do

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
      :address  => 'smtp.cox.net',
      :port  => 587,
      :domain => 'trask.net',
      :user_name  => 'jbtrask@cox.net',
      :password  => 'jbt123Zjbt123Z',
      :authentication  => :login,
      :enable_starttls_auto => true
  }

end
