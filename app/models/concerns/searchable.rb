# app/models/concerns/searchable.rb

module Searchable
  extend ActiveSupport::Concern

  included do
    scope :search_by_term, ->(term) {
      return all if term.blank?

      search_term = "%#{term.downcase}%"
      where(
        "LOWER(name) LIKE :search OR
         LOWER(email) LIKE :search OR
         phone LIKE :search OR
         LOWER(notes) LIKE :search",
        search: search_term
      )
    }

    scope :by_status, ->(status) {
      return all if status.blank?
      where(status: status)
    }

    scope :by_period, ->(period) {
      return all if period.blank?

      case period
      when "today"
        where(created_at: Date.current.all_day)
      when "this_week"
        where(created_at: Date.current.beginning_of_week..Date.current.end_of_week)
      when "this_month"
        where(created_at: Date.current.beginning_of_month..Date.current.end_of_month)
      when "last_3_months"
        where(created_at: 3.months.ago..Date.current)
      when "last_6_months"
        where(created_at: 6.months.ago..Date.current)
      when "this_year"
        where(created_at: Date.current.beginning_of_year..Date.current.end_of_year)
      when "last_year"
        where(created_at: 1.year.ago.beginning_of_year..1.year.ago.end_of_year)
      else
        all
      end
    }

    scope :by_value_range, ->(min, max) {
      query = all
      query = query.where("value >= ?", min.to_f) if min.present?
      query = query.where("value <= ?", max.to_f) if max.present?
      query
    }

    scope :by_date_range, ->(start_date, end_date) {
      query = all
      query = query.where("created_at >= ?", start_date) if start_date.present?
      query = query.where("created_at <= ?", end_date) if end_date.present?
      query
    }

    scope :sorted_by, ->(sort_option) {
      return order(:name) if sort_option.blank?

      case sort_option
      when "name"
        order(:name)
      when "name_desc"
        order(name: :desc)
      when "created_at_desc"
        order(created_at: :desc)
      when "created_at_asc"
        order(created_at: :asc)
      when "updated_at_desc"
        order(updated_at: :desc)
      when "value_desc"
        order(value: :desc)
      when "value_asc"
        order(value: :asc)
      when "email"
        order(:email)
      else
        order(:name)
      end
    }
  end

  class_methods do
    def apply_filters(params)
      results = all

      # Aplicar cada filtro em sequência
      results = results.search_by_term(params[:search])
      results = results.by_status(params[:status])
      results = results.by_period(params[:period])
      results = results.by_value_range(params[:min_value], params[:max_value])
      results = results.by_date_range(params[:created_after], params[:created_before])
      results = results.sorted_by(params[:sort_by])

      # Filtros adicionais específicos
      if params[:tags].present? && params[:tags].is_a?(Array)
        results = results.with_tags(params[:tags])
      end

      if params[:plan_type].present?
        results = results.where(plan_type: params[:plan_type])
      end

      results
    end

    def search_suggestions(term, limit = 5)
      return [] if term.blank? || term.length < 2

      search_by_term(term)
        .limit(limit)
        .pluck(:name, :email)
        .map { |name, email| { name: name, email: email } }
    end
  end
end
