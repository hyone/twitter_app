class HomeController < ApplicationController
  MESSAGE_PAGE_SIZE = 30

  def index
    if user_signed_in?
      @user    = current_user
      @message = @user.messages.build
      @feeds   = @user.timeline.page(params[:page]).per(MESSAGE_PAGE_SIZE)
    end
  end

  def about
  end
end
