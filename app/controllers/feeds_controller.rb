class FeedsController < ApplicationController

  def private
    @user = User.find_by_username( params[:user_id] )
    @microposts = @user.feed.limit(10) if @user

    respond_to do |extension|
      if @user && (params[:id] == @user.encrypted_password)
        extension.rss { render :layout => false }
      else
        extension.rss { render :nothing => true, :status => :forbidden }
      end
    end
  end
end
