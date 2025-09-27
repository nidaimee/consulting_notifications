class ProcessHistoryImagesJob < ApplicationJob
  queue_as :default

  def perform(client_history, images)
    images.each do |image|
      # ✅ Anexar imagem
      client_history.images.attach(image)

      # ✅ Processar/otimizar imagem se necessário
      if image.content_type.start_with?("image/")
        OptimizeImageJob.perform_later(client_history.images.last)
      end
    end

    # ✅ Notificar conclusão se necessário
    Rails.logger.info "Processed #{images.count} images for client_history #{client_history.id}"
  end
end
