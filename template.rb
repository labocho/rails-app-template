# encoding: UTF-8
# Usage: rails new name --template rails-template.rb --skip-test-unit

# ====================
# Gems
# ====================

gem "haml"
gem "kaminari"
gem "rails-i18n"

template_path = "#{File.dirname(__FILE__)}/templates/"

gem_group :development, :test do
  gem "debugger"
  gem "rspec-rails"
  gem "guard-rspec"
  gem "guard-spork"
  gem "rb-fsevent"
  gem "growl"
  gem "machinist"
  gem "thin"

  gem "turnip"
  gem "capybara-webkit"
  gem "launchy"
  gem "database_cleaner"

  gem "ci_reporter"
  gem "simplecov", require: false
  gem "simplecov-rcov", require: false
end

generate "rspec:install"
generate "machinist:install"

remove_file "spec/spec_helper.rb"
create_file "spec/spec_helper.rb", File.read(template_path + "spec_helper.rb")

if yes? "Do you use devise?"
  gem "devise"
  generate "devise:install"
end

if yes? "Do you use carrierwave?"
  gem "carrierwave"
  if yes? "mini_magick too?"
    gem "mini_magick"
  end
end

if yes? "Do you use mail?"
  gem "mail-iso-2022-jp"
  gem "action_mailer_config", git: "git://github.com/labocho/action_mailer_config.git"
  initializer "action_mailer_config.rb", File.read(template_path + "action_mailer_config.rb")

  gem "exception_notification", "~> 2.6.1"
  initializer "exception_notification.rb", File.read(template_path + "exception_notification.rb")
  puts <<-EOS
============================================================
Please edit config/initializers/exception_notification.rb
============================================================
EOS
end

# ====================
# Logging
# ====================

initializer "logger.rb", File.read(template_path + "logger.rb")

# ====================
# application.rb
# ====================
def application_multiline(data, options = {})
  indent = options[:env] ? "  " : "    "
  application data.gsub("\n", "\n#{indent}"), options
end

application_multiline <<-RUBY
config.generators do |g|
  g.template_engine :haml
  g.test_framework :rspec
  g.helper false
  g.stylesheets false
  g.javascripts false
end
RUBY

application_multiline <<-RUBY, env: :test
if Spork.using_spork?
  config.cache_classes = true
else
  config.cache_classes = false
end
RUBY
puts <<-EOS
============================================================
Please remove line below in config/environtments/test.rb

    config.cache_classes = false

============================================================
EOS

# ====================
# git
# ====================

git :init

# ====================
# initialize spork, guard
# ====================

run "spork --bootstrap"
run "guard init spork rspec"
