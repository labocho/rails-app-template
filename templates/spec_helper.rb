require 'simplecov'
require 'simplecov-rcov'

# rcov 形式と標準の HTML 形式両方を出力する
class SimpleCov::Formatter::MergedFormatter
  def format(result)
     SimpleCov::Formatter::HTMLFormatter.new.format(result)
     SimpleCov::Formatter::RcovFormatter.new.format(result)
  end
end
SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

SimpleCov.start do
  # spec 下、vendor 下はカバレッジ計測対象としない
  add_filter "/spec/"
  add_filter "/vendor/"
end

require 'spork'

Spork.prefork do
  ENV["RAILS_ENV"] = "test"
  require File.expand_path("../../config/environment.rb",  __FILE__)
  require "rspec/rails"
  require "machinist"

  Rails.backtrace_cleaner.remove_silencers!

  # Turnip の設定
  require "turnip"
  require "turnip/capybara"
  require "capybara-webkit"
  require "database_cleaner"
  Turnip.type = :request
  Capybara.javascript_driver = :webkit
  DatabaseCleaner.strategy = :truncation

  # Load support files
  Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

  RSpec.configure do |config|
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
    config.use_transactional_fixtures = false

    config.before(:each) do
      DatabaseCleaner.start
    end

    config.after(:each) do
      $d = nil # debugger if $d のように使う
      DatabaseCleaner.clean
    end

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"
  end
end

Spork.each_run do
  if Spork.using_spork?
    Rails.application.reloaders.each{|reloader| reloader.execute_if_updated }
    # クラス定義とともに blueprint も消えてしまうのでリロード
    load "#{File.dirname(__FILE__)}/support/blueprints.rb"
  end
end
