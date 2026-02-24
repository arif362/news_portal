# Structured JSON logging for production
# See https://github.com/roidrage/lograge

Rails.application.configure do
  config.lograge.enabled = Rails.env.production?

  # Use JSON format for structured logging (ELK, Datadog, CloudWatch compatible)
  config.lograge.formatter = Lograge::Formatters::Json.new

  # Include additional request data
  config.lograge.custom_options = lambda do |event|
    {
      time: Time.current.iso8601,
      host: event.payload[:host],
      request_id: event.payload[:request_id],
      user_agent: event.payload[:user_agent],
      ip: event.payload[:ip],
      exception: event.payload[:exception]&.first,
      exception_message: event.payload[:exception]&.last
    }.compact
  end

  # Include request parameters (filtered by filter_parameters)
  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      request_id: controller.request.request_id,
      user_agent: controller.request.user_agent,
      ip: controller.request.remote_ip
    }
  end
end
