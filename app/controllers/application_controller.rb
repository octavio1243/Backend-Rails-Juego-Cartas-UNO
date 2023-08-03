class ApplicationController < ActionController::Base

  private # Métodos auxiliares

  def check_token
    if current_user.blank?
      render(json: format_error('Token de sesión inválido'), status: 401)
    end
  end

  def current_user #Variable caché
    @current_user ||= User.find_by(token: request.headers["Authorization"])
  end

  def format_error(message)
    { messages: [ { path: request.path, message: message } ] }
  end

end
