class GenerateComparisonJob < ApplicationJob
  def perform(client, photo1_id, photo2_id, user_email)
    # Lógica de comparação de imagens
    # Enviar por email quando pronto
    UserMailer.comparison_ready(client, user_email).deliver_now
  end
end
