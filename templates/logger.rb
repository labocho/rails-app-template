# Assets のログを出力しない
Rails::Rack::Logger.class_eval do
  def call_with_quiet_assets(env)
    previous_level = Rails.logger.level
    Rails.logger.level = Logger::ERROR if env['PATH_INFO'].index("/assets/") == 0
    call_without_quiet_assets(env).tap do
      Rails.logger.level = previous_level
    end
  end
  alias_method_chain :call, :quiet_assets
end

# ログで Parameters を pretty print 表示
require "action_controller/log_subscriber"
require "pp"
ActionController::LogSubscriber.class_eval do
  def start_processing(event)
    payload = event.payload
    params  = payload[:params].except(*INTERNAL_PARAMS)
    format  = payload[:format]
    format  = format.to_s.upcase if format.is_a?(Symbol)

    info "Processing by #{payload[:controller]}##{payload[:action]} as #{format}"
    info "  Parameters:\n#{params.pretty_inspect.lines.map{|l| "    #{l}"}.join}" unless params.empty?
  end
end
