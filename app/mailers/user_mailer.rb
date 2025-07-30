class UserMailer < ApplicationMailer
  default from: 'noreply@example.com'

  def welcome_email(user, password, organization)
    @user = user
    @password = password
    @organization = organization
    @login_url = root_url

    # In development, log credentials instead of sending email
    if Rails.env.development?
      Rails.logger.info "=== USER ACCOUNT CREATED ==="
      Rails.logger.info "Email: #{@user.email}"
      Rails.logger.info "Password: #{@password}"
      Rails.logger.info "Organization: #{@organization.name}"
      Rails.logger.info "Login URL: #{@login_url}"
      Rails.logger.info "============================="
    end

    mail(to: @user.email, subject: "Welcome to #{@organization.name}")
  end
end
