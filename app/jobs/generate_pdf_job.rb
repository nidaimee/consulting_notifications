class GeneratePdfJob < ApplicationJob
  def perform(client, html, user_email)
    pdf = WickedPdf.new.pdf_from_string(html, ...)
    UserMailer.pdf_ready(client, pdf, user_email).deliver_now
  end
end