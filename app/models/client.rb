# app/models/client.rb

class Client < ApplicationRecord
  include Searchable
  # Associações
  belongs_to :user
  has_many :diets, dependent: :destroy
  has_many :client_histories, dependent: :destroy
  validates :start_date, :end_date, presence: true
  # Validações
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone_number, format: { with: /\A[\d\s\-\(\)]+\z/ }, allow_blank: true
  validates :paid_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, inclusion: { in: %w[active expiring expired] }
  validates :age, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :height, numericality: { greater_than: 0 }, allow_nil: true
  SEXES = %w[Masculino Feminino]
  # Callbacks
  before_save :set_automatic_status
  before_validation :set_default_status, on: :create
  before_validation :set_automatic_status, on: [ :create, :update ]

  scope :active_records, -> { where(archived_at: nil) }  # Clientes não arquivados
  scope :archived, -> { where.not(archived_at: nil) }    # Clientes arquivados

  scope :default, -> { where(archived_at: nil) }

  def automatic_status
    return "active" if start_date.blank? || end_date.blank?

    days_remaining = (end_date - Date.current).to_i

    case days_remaining
    when ...-1
      "expired"      # Já passou da data
    when 0..7
      "expiring"     # Faltam 7 dias ou menos
    else
      "active"       # Mais de 7 dias restantes
    end
  end

  def update_automatic_status!
    new_status = automatic_status
    update_column(:status, new_status) if status != new_status
  end

  def expired?
    end_date.present? && end_date < Date.current
  end

  def expiring?(days = 7)
    end_date.present? && end_date.between?(Date.current, days.days.from_now)
  end

  def days_remaining
    return nil unless end_date.present?
    (end_date - Date.current).to_i
  end

  def archive!
  update!(archived_at: Time.current)
  end

  def unarchive!
    update!(archived_at: nil)
  end

  def archived?
    archived_at.present?
  end

  def plan_type_humanized
    case plan_type
    when "mensal"
      "Mensal"
    when "trimestral"
      "Trimestral"
    when "semestral"
      "Semestral"
    when "anual"
      "Anual"
    else
      "Não informado"
    end
  end

  def mensal?
    plan_type == "mensal"
  end

  def trimestral?
    plan_type == "trimestral"
  end

  def semestral?
    plan_type == "semestral"
  end

  def anual?
    plan_type == "anual"
  end

  def self.plan_type_options
    [
      [ "Mensal", "mensal" ],
      [ "Trimestral", "trimestral" ],
      [ "Semestral", "semestral" ],
      [ "Anual", "anual" ]
    ]
  end



  scope :active, -> { where(status: "active", archived_at: nil) }
  scope :expiring, -> { where(status: "expiring", archived_at: nil) }
  scope :expired, -> { where(status: "expired", archived_at: nil) }

  # Imagens
  has_many_attached :photos

  # Scopes de período
  scope :current, -> { where("end_date >= ?", Date.current) }
  scope :expired, -> { where("end_date < ?", Date.current) }
  scope :expiring, ->(days = 7) { where("end_date BETWEEN ? AND ?", Date.current, days.days.from_now) }

  # Scopes de contato
  scope :recently_contacted, ->(days = 7) { where("last_contacted_at >= ?", days.days.ago) }
  scope :not_contacted_recently, ->(days = 30) { where("last_contacted_at < ? OR last_contacted_at IS NULL", days.days.ago) }
  scope :never_contacted, -> { where(last_contacted_at: nil) }

  # Scopes de atualização
  scope :to_be_updated_soon, ->(days = 7) {
  where("next_update_at BETWEEN ? AND ?", Date.current, Date.current + days)
    .order(next_update_at: :asc)
  }

  def next_update_date
    last_history = client_histories.order(next_update_at: :desc).where.not(next_update_at: nil).first
    last_history&.next_update_at || next_update_at
  end
  # Scopes de busca
  scope :search_by_term, ->(term) {
    return all if term.blank?

    # Usar índices compostos para melhor performance
    joins("LEFT JOIN diets ON diets.client_id = clients.id")
    .where(
      "clients.name ILIKE :search OR
       clients.email ILIKE :search OR
       clients.phone_number ILIKE :search",
      search: "%#{term}%"
    )
    .distinct
  }

  scope :by_paid_amount_range, ->(min, max) {
    query = all
    query = query.where("paid_amount >= ?", min) if min.present?
    query = query.where("paid_amount <= ?", max) if max.present?
    query
  }

  # Métodos de classe
  def self.apply_filters(params)
    results = all

    results = results.search_by_term(params[:search]) if params[:search].present?
    results = results.where(status: params[:status]) if params[:status].present?
    results = results.by_paid_amount_range(params[:min_paid_amount], params[:max_paid_amount])

    # Filtro por período
    case params[:period]
    when "current"
      results = results.current
    when "expired"
      results = results.expired
    when "expiring"
      results = results.expiring
    end

    # Ordenação
    case params[:sort_by]
    when "name"
      results = results.order(:name)
    when "created_at_desc"
      results = results.order(created_at: :desc)
    when "created_at_asc"
      results = results.order(created_at: :asc)
    when "paid_amount_desc"
      results = results.order(paid_amount: :desc)
    when "paid_amount_asc"
      results = results.order(paid_amount: :asc)
    when "last_contacted_at_desc"
      results = results.order(last_contacted_at: :desc)
    when "end_date_asc"
      results = results.order(end_date: :asc)
    else
      results = results.order(:name)
    end

    results
  end

  # Métodos de instância
  def active?
    status == "active"
  end

  def inactive?
    status == "inactive"
  end

  def pending?
    status == "pending"
  end

  def expired?
    end_date && end_date < Date.current
  end

  def expiring?(days = 7)
    return false unless end_date
    end_date.between?(Date.current, days.days.from_now)
  end

  def days_remaining
    return nil unless end_date
    (end_date - Date.current).to_i
  end

  def days_since_last_contact
    return nil unless last_contacted_at
    (Date.current - last_contacted_at.to_date).to_i
  end

  def needs_contact?(days = 30)
    last_contacted_at.nil? || days_since_last_contact > days
  end

  def mark_as_contacted!
    update!(last_contacted_at: Time.current)
  end

  def formatted_phone
    return nil if phone_number.blank?

    digits = phone_number.gsub(/\D/, "")

    case digits.length
    when 11
      "(#{digits[0..1]}) #{digits[2..6]}-#{digits[7..10]}"
    when 10
      "(#{digits[0..1]}) #{digits[2..5]}-#{digits[6..9]}"
    else
      phone_number
    end
  end

  def display_name
    name.presence || email.presence || "Cliente sem nome"
  end

  def to_s
    display_name
  end

  private

  def set_automatic_status
    self.status = automatic_status unless archived_at.present?
  end

  def set_default_status
    self.status ||= "active"
  end
end
