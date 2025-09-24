module ClientsHelper
  def plan_type_badge_class(plan_type)
    case plan_type&.downcase
    when "mensal"
      "inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800"
    when "trimestral"
      "inline-flex items-center rounded-full bg-blue-100 px-2.5 py-0.5 text-xs font-medium text-blue-800"
    when "semestral"
      "inline-flex items-center rounded-full bg-purple-100 px-2.5 py-0.5 text-xs font-medium text-purple-800"
    when "anual"
      "inline-flex items-center rounded-full bg-yellow-100 px-2.5 py-0.5 text-xs font-medium text-yellow-800"
    else
      "inline-flex items-center rounded-full bg-gray-100 px-2.5 py-0.5 text-xs font-medium text-gray-800"
    end
  end

  def plan_type_duration(plan_type)
    case plan_type&.downcase
    when "mensal"
      "1 mês"
    when "trimestral"
      "3 meses"
    when "semestral"
      "6 meses"
    when "anual"
      "12 meses"
    else
      "-"
    end
  end
end
