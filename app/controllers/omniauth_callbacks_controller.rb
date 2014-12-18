class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :get_omniauth

  def twitter
    @omniauth['info']['_account_name'] = @omniauth['info']['nickname']
    @omniauth['info']['_url']          = @omniauth['info']['urls']['Twitter']
    create_authentication(@omniauth)
  end

  def github
    @omniauth['info']['_account_name'] = @omniauth['info']['nickname']
    @omniauth['info']['_url']          = @omniauth['info']['urls']['GitHub']
    create_authentication(@omniauth)
  end

  def google_oauth2
    @omniauth['info']['_account_name'] = @omniauth['info']['email']
    @omniauth['info']['_url']          = @omniauth['info']['urls']['Google']
    create_authentication(@omniauth)
  end

  private
  def get_omniauth
    @omniauth = request.env['omniauth.auth']
    if Rails.env.development?
      puts @omniauth.to_yaml
    end
  end


  def create_authentication(omniauth)
    authentication = Authentication.find_by(
      provider: omniauth['provider'],
      uid: omniauth['uid']
    )

    if authentication
      flash[:notice] = t('devise.omniauth_callbacks.success', kind: omniauth['provider'])
      sign_in authentication.user
      redirect_to root_path
    elsif current_user
      current_user.apply_omniauth(omniauth).save!
      flash[:notice] = t('devise.omniauth_callbacks.success', kind: omniauth['provider'])
      redirect_to root_path
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = t('devise.omniauth_callbacks.success', kind: omniauth['provider'])
        sign_in user
        redirect_to root_path
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_registration_url
      end
    end
  end
end