require 'base64'

class V1::UsersController < ApplicationController

  skip_before_action :verify_authenticity_token

  before_action :check_token, only: [:destroy, :logout, :password, :image, :name, :show]

  # Métodos default

  def index
    image_url = "#{request.base_url}/images/null_profile.png"
    user = User.find(5)
    if user.image.attached?
      image_url = url_for(user.image)
    end
    render plain: image_url
  end

  def update
  end

  def get
  end

  def destroy
  end

  def show
    begin
      user = User.find(params[:id])
      msg, status = [{"name": user.name, "email": user.email, "image_url": get_image_url(user)}, 200]
    rescue ActiveRecord::RecordNotFound
      msg, status = [format_error("User not found"), 404]
    end
    render(json: msg, status: status)
  end

  # Métodos para rutas

  def register
    user = User.new(user_params)
    msg , status = user.save ? [ {"id":user.id,"token":user.token} , 200 ] : [format_error(user.errors.full_messages),400]
    render(json: msg, status: status)
  end

  def login
    user = User.find_by(email: user_params[:email])
    if user && user.authenticate(user_params[:password])
      render json: { id: user.id, token: user.token }, status: 200
    else
      render json: format_error('Credenciales de inicio de sesión incorrectas'), status: 400
    end
  end

  def logout
    if current_user.update_token
      head :ok
    else
      render(json: format_error(current_user.errors.full_messages), status: 401)
    end
  end

  def password
    if current_user.authenticate(params["current_password"])
      if current_user.update(password: params["new_password"])
        head :ok
      else
        render(json: format_error(current_user.errors.full_messages), status: 401)
      end
    else
      render(json: format_error('La contraseña actual es incorrecta'), status: 401)
    end
  end
  
  def image
    image_string = params[:image]
    if !image_string.empty?
      decoded_data = Base64.decode64(image_string)
      file = StringIO.new(decoded_data)
      current_user.image.attach(io: file, filename: 'image.png', content_type: 'image/png')
      head :ok
    else
      render(json: format_error('Error al cargar imagen'), status: 400)
    end
  end

  def destroy
    current_user.delete 
    head :ok
  end

  private

  def user_params
    #params.require(:user).permit(:name, :email, :password, :image)
    params.permit(:name, :email, :password, :image)
  end

  def get_image_url(user)
    image_url = "#{request.base_url}/images/null_profile.png"
    if user.image.attached?
      image_url = url_for(user.image)
    end
    return image_url
  end

end
