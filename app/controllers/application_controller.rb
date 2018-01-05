class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:valid_flg])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:valid_flg])
    devise_parameter_sanitizer.permit(:account_update, keys: [:valid_flg])
    devise_parameter_sanitizer.permit(:sign_up, keys: [:admin_flg])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:admin_flg])
    devise_parameter_sanitizer.permit(:account_update, keys: [:admin_flg])
  end

end
