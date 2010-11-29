require 'crypto'

class PasswordRemindersController < ApplicationController
  def new
    @title = "Recover password"
  end

  def create
    user = User.find_by_username( params[:username] )
    if user
      token = Crypto.encrypt("#{ user.username }:#{ user.salt }")
      UserMailer.password_recovery(:token => token, :email => user.email,
        :host => request.env['HTTP_HOST']).deliver
      flash[:notice] = "Please check your email"
      redirect_to root_url
    else
      flash[:error] = "Can't find username: #{params[:username]}"
      redirect_to root_url
    end
  end

  def reset
    begin
      username, salt = Crypto.decrypt(params[:id]).split(":")
      user = User.find_by_username(username, :conditions => ["salt = ?", salt])
      sign_in( user )
      flash.now[:notice] = "Please enter a new password."
      redirect_to edit_user_path( user )
    rescue => err
      flash[:error] = "The recovery link given is not valid."
      redirect_to root_url
    end
  end
end
