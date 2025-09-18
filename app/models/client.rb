# app/models/client.rb

class Client < ApplicationRecord
  # Associações
  belongs_to :user
  has_many :diets, dependent: :destroy
  # Validações
  validates :name, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :phone_number, format: { with: /\A[\d\s\-\(\)]+\z/ }, allow_blank: true
  validates :paid_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :status, inclusion: { in: %w[active inactive pending] }

  # Callbacks
  before_validation :set_default_status, on: :create

  # Scopes básicos
  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }
  scope :pending, -> { where(status: "pending") }

  # Scopes de período
  scope :current, -> { where("end_date >= ?", Date.current) }
  scope :expired, -> { where("end_date < ?", Date.current) }
  scope :expiring_soon, ->(days = 7) { where("end_date BETWEEN ? AND ?", Date.current, days.days.from_now) }

  # Scopes de contato
  scope :recently_contacted, ->(days = 7) { where("last_contacted_at >= ?", days.days.ago) }
  scope :not_contacted_recently, ->(days = 30) { where("last_contacted_at < ? OR last_contacted_at IS NULL", days.days.ago) }
  scope :never_contacted, -> { where(last_contacted_at: nil) }

  # Scopes de busca
  scope :search_by_term, ->(term) {
    return all if term.blank?

    search_term = "%#{term.downcase}%"
    where(
      "LOWER(name) LIKE :search OR
       LOWER(email) LIKE :search OR
       phone_number LIKE :search OR
       LOWER(note) LIKE :search",
      search: search_term
    )
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
    when "expiring_soon"
      results = results.expiring_soon
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

  def expiring_soon?(days = 7)
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

  def set_default_status
    self.status ||= "active"
  end
end
