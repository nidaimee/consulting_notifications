class RegistrationsController < Devise::RegistrationsController
  include TailadminLayout

  # GET /users/edit
  def edit
    super
  end

  # PATCH/PUT /users
  def update
    super
  end

  protected

  def update_resource(resource, params)
    # Se não há senha atual fornecida e o usuário não quer alterar a senha
    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
      params.delete(:current_password)
      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :phone ])
  end
end
