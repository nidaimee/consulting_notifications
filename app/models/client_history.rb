class ClientHistory < ApplicationRecord
  belongs_to :client
  belongs_to :user, optional: true
  # Imagens
  has_many_attached :images


  validates :description, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def formatted_date
    created_at.strftime("%d/%m/%Y às %H:%M")
  end
end
