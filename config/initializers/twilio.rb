# config/initializers/twilio.rb
require "twilio-ruby"

account_sid = Rails.application.credentials.twilio[:account_sid]
auth_token  = Rails.application.credentials.twilio[:auth_token]

TWILIO_CLIENT = Twilio::REST::Client.new(account_sid, auth_token)
