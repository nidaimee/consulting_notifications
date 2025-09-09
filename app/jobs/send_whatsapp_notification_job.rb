class SendWhatsappNotificationJob < ApplicationJob
  queue_as :default

  def perform(client_id)
    client = Client.find(client_id)
    return unless client.needs_contact?

    message = TWILIO_CLIENT.messages.create(
      from: "whatsapp:+14155238886",
      to: "whatsapp:+553391181490",
      body: "Your appointment is coming up!"
    )

    Notification.create!(
      client: client,
      message: message,
      sent_at: Time.current,
      medium: "whatsapp"
    )

    client.update(last_contacted_at: Time.current)
  end
end
