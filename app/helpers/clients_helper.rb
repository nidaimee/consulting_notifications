module ClientsHelper
  def client_status_color(status)
    case status&.to_s
    when "active"
      "success"
    when "inactive"
      "danger"
    when "pending"
      "warning"
    else
      "secondary"
    end
  end
end
