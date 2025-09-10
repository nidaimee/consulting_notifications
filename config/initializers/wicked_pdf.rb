# Detectar wkhtmltopdf automaticamente
wkhtmltopdf_path = nil

# Tentar diferentes localizações comuns
possible_paths = [
  '/usr/local/bin/wkhtmltopdf',
  '/usr/bin/wkhtmltopdf',
  '/bin/wkhtmltopdf',
  `which wkhtmltopdf`.strip
]

possible_paths.each do |path|
  if File.exist?(path) && File.executable?(path)
    wkhtmltopdf_path = path
    break
  end
end

if wkhtmltopdf_path
  WickedPdf.config = {
    exe_path: wkhtmltopdf_path,
    enable_local_file_access: true
  }
  puts "WickedPDF configurado com: #{wkhtmltopdf_path}"
else
  puts "AVISO: wkhtmltopdf não encontrado. PDF pode não funcionar."
  # Usar configuração padrão da gem
  WickedPdf.config = {
    enable_local_file_access: true
  }
end
