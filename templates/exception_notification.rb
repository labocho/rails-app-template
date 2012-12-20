Rails.application.config.middleware.use(
  ExceptionNotifier,
  :email_prefix => "[Application name] ",
  :sender_address => %{"Sender name" <sender-address>},
  :exception_recipients => %w{recipient-addresses}
)
