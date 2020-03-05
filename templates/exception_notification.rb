unless Rails.env == "development"
  Rails.application.config.middleware.use(
    ExceptionNotification::Rack,
    email: {
      email_prefix: "[Application name] ",
      sender_address: %{"Sender name" <sender-address>},
      exception_recipients: %w{recipient-addresses},
    },
  )
end
