require "lograge"

module Lograge
  # アップロードされたファイルの内容をログに出力しないようにする
  def self.filter_uploaded_file(obj)
    case obj
    when Array
      obj.map{|e| filter_uploaded_file(e) }
    when Hash
      obj.each_with_object({}) do |(k, v), hash|
        hash[k] = filter_uploaded_file(v)
      end
    when ActionDispatch::Http::UploadedFile
      obj.inspect
    else
      obj
    end
  end
end

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = -> (event) {
    time = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - event.time).seconds.ago

    params = event.payload[:params].reject do |k|
      %w(controller action).include? k
    end

    params = Lograge.filter_uploaded_file(params)

    {
      "session_id" => event.payload[:session_id],
      "remote_ip" => event.payload[:remote_ip],
      "user_id" => event.payload[:user_id],
      "params" => params,
      "time" => time.to_i,
    }
  }
end
