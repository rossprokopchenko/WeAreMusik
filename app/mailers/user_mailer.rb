class UserMailer < ApplicationMailer
  default from: "no-reply@wearemusik.com"

  def verification_email(user)
    @user = user
    mail(
      to: @user.email_address,
      subject: "Your Verification Code for WeAreMusik"
    )
  end

  def welcome_email(user)
    @user = user
    mail(to: @user.email_address, subject: "Welcome to WeAreMusik!")
  end
end
