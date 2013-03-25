# encoding: UTF-8

template_path = "#{File.dirname(__FILE__)}/templates/"

# ====================
# Gems
# ====================

gem "haml"
gem "kaminari"
gem "rails-i18n"

gem_group :development, :test do
  gem "debugger"
  gem "rspec-rails"
  gem "guard-rspec"
  gem "guard-spork"
  gem "rb-fsevent" # Mac で guard 使うのに必要
  gem "growl" # guard から growl に通知
  gem "machinist" # Fixture replacement
  gem "thin" # WEBrick より早く 1.9.3 で安定

  gem "turnip" # Cucumber と同じ書式の受け入れテストを rspec で実行
  gem "capybara-webkit" # turnip で JS 含むテストを実行
  gem "launchy" # turnip でブラウザで確認
  gem "database_cleaner" # capybara-webkit 使うと transactional_fixture 使えないので代わりに

  gem "ci_reporter" # Jenkins 用にテスト結果を XML で出力
  gem "simplecov", require: false # コードカバレッジ計測・出力
  gem "simplecov-rcov", require: false # Jenkins 用にコードカバレッジを rcov 形式で出力
end

generate "rspec:install"
generate "machinist:install" # spec/supports/blueprints.rb

# spec_helper.rb を置き換え
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
  gem "mail-iso-2022-jp" # ActionMailer で ISO-2022-JP のメールを送信可能に
  gem "action_mailer_config", git: "git://github.com/labocho/action_mailer_config.git" # ActionMailer の設定を mail.yml で
  initializer "action_mailer_config.rb", File.read(template_path + "action_mailer_config.rb")

  gem "exception_notification", "~> 2.6.1" # 例外をメールで通知 / 3.0.0 は Encoding 関係で例外が出る
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

# ログを見やすくする
initializer "logger.rb", File.read(template_path + "logger.rb")

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

# spork でクラスリロードするための設定
application_multiline <<-RUBY, env: :test
if Spork.using_spork?
  config.cache_classes = false
else
  config.cache_classes = true
end
RUBY
puts <<-EOS
============================================================
Please remove line below in config/environtments/test.rb

    config.cache_classes = true

============================================================
EOS

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

# ====================
# initialize spork, guard
# ====================

run "bundle exec guard init spork rspec" # Guardfile 生成
