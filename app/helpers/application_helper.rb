module ApplicationHelper
  def translate_enum(model, attribute, value)
  I18n.t("#{model.model_name.i18n_key}.#{attribute.to_s.pluralize}.#{value}",
          default: value.to_s.humanize)
  end

  def meal_type_name(meal_type)
    return "Não definido" if meal_type.blank?
    I18n.t("meal_types.#{meal_type}", default: meal_type.humanize)
  end

  def plan_type_name(plan_type)
    return "Não definido" if plan_type.blank?
    I18n.t("plan_types.#{plan_type}", default: plan_type.humanize)
  end

  def status_name(status)
    return "Não definido" if status.blank?
    I18n.t("status.#{status}", default: status.humanize)
  end

  def client_status_translation(status)
    case status
    when "active"
      "Ativo"
    when "expiring"
      "Expira em Breve"
    when "expired"
      "Período Finalizado"
    else
      "Ativo"
    end
  end

  def client_status_color(status)
    case status
    when "active"
      "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200"
    when "expiring"
      "bg-amber-100 text-amber-800 dark:bg-amber-900 dark:text-amber-200"
    when "expired"
      "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200"
    else
      "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200"
    end
  end

  def client_status_with_days(client)
    case client.status
    when "active"
      days = client.days_remaining
      if days && days > 7
        "Ativo (#{days} dias restantes)"
      else
        "Ativo"
      end
    when "expiring"
      days = client.days_remaining
      if days && days >= 0
        "⚠️ Expira em #{days} dia#{'s' if days != 1}"
      else
        "⚠️ Expira em Breve"
      end
    when "expired"
      days = client.days_remaining
      if days && days < 0
        "🔴 Expirado há #{days.abs} dia#{'s' if days.abs != 1}"
      else
        "🔴 Período Finalizado"
      end
    else
      client_status_translation(client.status)
    end
  end
end
