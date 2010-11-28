class UserMailer < ActionMailer::Base
  default :from => "no@example.com"

  def follower_notification(followed, follower)
    @followed, @follower = followed, follower
    mail(:to => @followed.email, :subject => "Follower notification")
  end
end
