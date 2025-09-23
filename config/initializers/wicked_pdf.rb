WickedPdf.configure do |config|
  # Detectar wkhtmltopdf automaticamente
  wkhtmltopdf_path = nil

  possible_paths = [
    "/usr/local/bin/wkhtmltopdf",
    "/usr/bin/wkhtmltopdf",
    "/bin/wkhtmltopdf",
    `which wkhtmltopdf`.strip
  ]

  possible_paths.each do |path|
    if File.exist?(path) && File.executable?(path)
      wkhtmltopdf_path = path
      break
    end
  end

  config.enable_local_file_access = true
  config.exe_path = wkhtmltopdf_path if wkhtmltopdf_path
end
