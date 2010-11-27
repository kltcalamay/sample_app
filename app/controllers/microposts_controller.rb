class MicropostsController < ApplicationController
  before_filter :authenticate, :only => [:create, :destroy]
  before_filter :authorized_user, :only => :destroy
  before_filter :process_direct_message, :only => :create

  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_path
    else
      @feed_items = []
      render 'pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_back_or root_path
  end

  private

    def authorized_user
      @micropost = Micropost.find(params[:id])
      redirect_to root_path unless current_user?(@micropost.user)
    end

    def process_direct_message
      @micropost = current_user.microposts.build(params[:micropost])
      if @micropost.direct_message_format?
        direct_message = DirectMessage.new(@micropost.to_direct_message_hash)
        redirect_to root_path if direct_message.save
      end
    end
end
