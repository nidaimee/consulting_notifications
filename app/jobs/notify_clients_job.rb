class NotifyClientsJob < ApplicationJob
  queue_as :default

  def perform
    Client.all.each do |client|
      if client.needs_contact?
        # Aqui você envia o email
        ClientMailer.reminder_email(client).deliver_now

        # Atualiza a data do último contato
        client.update(last_contacted_at: Time.current)
      end
    end
  end
end
