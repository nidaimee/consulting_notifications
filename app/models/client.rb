class Client < ApplicationRecord
  belongs_to :user
  has_many :diets, dependent: :destroy

  validates :name, presence: true
  validates :phone_number, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :paid_amount, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: [ "active", "inactive", "completed" ] }

  def current_status
    return "completed" if Date.current > end_date
    return "active" if Date.current >= start_date && Date.current <= end_date
    "inactive"
  end

  def active?
    status == "active"
  end

  def inactive?
    status == "inactive"
  end

  def completed?
    status == "completed"
  end
end

# ===============================================
# COMANDOS PARA CORRIGIR
# ===============================================

# 1. Sair do Rails console se estiver dentro
# exit

# 2. Editar o arquivo app/models/client.rb
# Use uma das versões acima (com enum correto OU sem enum)

# 3. Testar novamente
# rails console

# 4. Verificar se funcionou:
# puts Client.column_names
# User.first.clients.count

# ===============================================
# VERSÃO FINAL RECOMENDADA (SEM ENUM)
# ===============================================
