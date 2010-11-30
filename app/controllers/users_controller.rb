require 'crypto'

class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create, :confirm]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy

  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end
  
  def show
    @user = User.find_by_username(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = "Sign up"
  end

  def edit
    @title = "Edit user"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      UserMailer.signup_confirmation(:host => request.env['HTTP_HOST'],
        :token => Crypto.encrypt("#{@user.id}"), :email => @user.email).deliver
      flash[:notice] = "To complete registration, please check your email."
      redirect_to root_url
    else
      @title = "Sign up"
      render 'new'
    end
  end

  def edit
    @user = User.find_by_username(params[:id])
    @title = "Edit user"
  end

  def update
    @user = User.find_by_username(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    User.find_by_username(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_path
  end

  def following
    @title = "Following"
    @user = User.find_by_username(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find_by_username(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end

  def confirm
    begin
      user = User.find( Crypto.decrypt(params[:id]) )
      user.activate!
      sign_in( user )
      flash[:success] = "Account confirmed. Welcome #{user.name}!"
      redirect_to root_url
    rescue Transitions::InvalidTransition
      sign_out if signed_in?
      flash[:notice] = "Account is already activated. Please sign in instead."
      redirect_to signin_path
    rescue
      flash[:error] = "Invalid confirmation token."
      redirect_to root_url
    end
  end

  private

    def correct_user
      @user = User.find_by_username(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end

