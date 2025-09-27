class GeneratePdfJob < ApplicationJob
  def perform(client, html, user_email)
    # Explicitly pass any required options instead of using `...`
    pdf_options = { encoding: "UTF-8" } # Example options for WickedPdf
    pdf = WickedPdf.new.pdf_from_string(html, pdf_options)
    UserMailer.pdf_ready(client, pdf, user_email).deliver_now
  end
end
