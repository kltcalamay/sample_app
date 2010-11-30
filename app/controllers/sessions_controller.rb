class SessionsController < ApplicationController

  def new
    @title = "Sign in"
  end

  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid email/password combination."
      @title = "Sign in"
      render 'new'
    else
      if user.state == "inactive"
        flash[:error] = "Your account isn't confirmed. Please check your email."
        redirect_to root_url
      else
        sign_in user
        redirect_back_or user
      end
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
