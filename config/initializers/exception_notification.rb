airbrake_api_key = Gitorious::Configuration.get("airbrake_api_key")

if airbrake_api_key
  require 'airbrake'

  Airbrake.configure do |config|
    config.api_key = airbrake_api_key
  end

  # Manually register Airbrake's middleware as Rails doesn't initialize any
  # railtie that is registered after the initialization process started.
  Gitorious::Application.config.middleware.insert(0, "Airbrake::UserInformer")
  Gitorious::Application.config.middleware.insert_after(
    "ActionDispatch::DebugExceptions", "Airbrake::Rails::Middleware"
  )
else
  exception_recipients = Gitorious::Configuration.get("exception_recipients")

  if Rails.env.production? && exception_recipients.blank?
    $stderr.puts "WARNING! No value set for exception_recipients in gitorious.yml."
    $stderr.puts "Will not be able to send email regarding unhandled exceptions"
  else
    require "exception_notifier"

    Gitorious::Application.config.middleware.use(ExceptionNotifier, {
      :email_prefix => "[Gitorious] ",
      :sender_address => Gitorious.email_sender,
      :exception_recipients => exception_recipients
    })
  end
end