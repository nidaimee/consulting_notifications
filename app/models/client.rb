class Client < ApplicationRecord
  # Método que verifica se é hora de notificar
  def needs_contact?
    last_contacted_at.nil? || last_contacted_at <= 2.weeks.ago
  end
end
