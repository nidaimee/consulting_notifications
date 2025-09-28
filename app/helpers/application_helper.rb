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
end
