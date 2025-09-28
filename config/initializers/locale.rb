# Configurações de localização
Rails.application.configure do
  # Definir locale padrão
  config.i18n.default_locale = :'pt-BR'

  # Localizar números e datas automaticamente
  config.i18n.fallbacks = [ I18n.default_locale ]
end

# Configurar timezone para Brasil
Time.zone = "America/Sao_Paulo"
