class SendWhatsappNotificationJob < ApplicationJob
  queue_as :default

  def perform(client_id)
    client = Client.find(client_id)
    return unless client.needs_contact?

    message_body = "Olá #{client.name}, está na hora de nossa consultoria!"

    TWILIO_CLIENT.messages.create(
      from: TWILIO_WHATSAPP_NUMBER,
      to: "whatsapp:#{client.phone_number}",
      body: message_body
    )

    Notification.create!(
      client: client,
      message: message_body,
      sent_at: Time.current,
      medium: "whatsapp"
    )

    client.update(last_contacted_at: Time.current)
  end
end
