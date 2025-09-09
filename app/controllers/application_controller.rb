class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :phone, :specialty, :license_number])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :phone, :specialty, :license_number])
  end
end
