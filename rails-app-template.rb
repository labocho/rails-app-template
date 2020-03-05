# encoding: UTF-8

template_path = "#{File.dirname(__FILE__)}/templates/"

# ====================
# Gems
# ====================

gem "haml"
gem "kaminari"
gem "rails-i18n"

gem_group :development, :test do
  gem "byebug"
  gem "rspec-rails"
  gem "factory_girl_rails" # Fixture replacement
end

generate "rspec:install"

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
  gem "action_mailer_config", git: "git://github.com/labocho/action_mailer_config.git" # ActionMailer の設定を mail.yml で
  initializer "action_mailer_config.rb", File.read(template_path + "action_mailer_config.rb")

  gem "exception_notification" # 例外をメールで通知
  initializer "exception_notification.rb", File.read(template_path + "exception_notification.rb")
  puts <<-EOS
============================================================
Please edit config/initializers/exception_notification.rb
============================================================
EOS
end

run "bundle install" # 以下でコマンド実行するため bundle install しておく

# ====================
# Logging
# ====================

# ====================
# application.rb
# ====================
# application メソッドに複数行の文字列渡すとインデントがおかしくなるので調整
def application_multiline(data, options = {})
  indent = options[:env] ? "  " : "    "
  application data.gsub("\n", "\n#{indent}"), options
end

# rails g scaffold で使用する generator を指定
# helper / css / js は生成しない
application_multiline <<-RUBY
config.generators do |g|
  g.template_engine :haml
  g.test_framework :rspec
  g.helper false
  g.stylesheets false
  g.javascripts false
end
RUBY

# ====================
# template
# ====================

# lib/templates 下に rails g で使うテンプレートを展開
rake "rails:templates:copy"
# haml のテンプレートをコピー
directory(template_path + "generators", "lib/generators")

# ====================
# git
# ====================

git :init
