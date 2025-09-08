class ClientMailer < ApplicationMailer
  default from: "dutrarg1@gmail.com"

  def reminder_email(client)
    @client = client
    mail(to: "dutrarg1@gmail.com", subject: "Hora de falar com #{@client.name}")
  end
end
