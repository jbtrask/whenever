class LightsMailer < ActionMailer::Base
  default from: "no-reply@trask.net"

  def test_email
    mail(to: "jbt_5@yahoo.com", subject: "AMAZING test email")
  end

end
