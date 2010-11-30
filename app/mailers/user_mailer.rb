class UserMailer < ActionMailer::Base
  default :from => "microblog@kennethcalamay.com"

  def follower_notification(followed, follower)
    @followed, @follower = followed, follower
    mail(:to => @followed.email, :subject => "Follower notification")
  end

  def password_recovery(options)
    @recovery_uri =
      "http://#{options[:host]}#{reset_password_reminder_path(options[:token])}"
    mail(:to => options[:email], :host => options[:domain])
  end

  def signup_confirmation(options)
    @confirmation_uri =
      "http://#{options[:host]}#{ confirm_user_path(options[:token]) }"
    mail(:to => options[:email], :host => options[:domain])
  end
end
