class SendWhatsappNotificationJobWrapper
  def perform
    Client.all.each do |client|
      SendWhatsappNotificationJob.perform_later(client.id)
    end
  end
end
