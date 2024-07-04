# encoding: UTF-8
require "open-uri"
require "fileutils"

template_path = "#{File.dirname(__FILE__)}/templates/"

# Gems
# ====================
gem "haml"
gem "kaminari"
gem "rails-i18n"

gem_group :development, :test do
  gem "byebug"
  gem "factory_bot_rails"
  gem "timecop"
end

# draper
# --------------------
gem "draper"
initializer "draper.rb", File.read(template_path + "draper.rb")

# lograge
# --------------------
gem "lograge"
initializer "lograge.rb", File.read(template_path + "lograge.rb")

append_info_to_payload = <<-RUBY
  private
  def append_info_to_payload(payload)
    super
    payload[:session_id] = session.id
    # payload[:user_id] = current_user&.id
    payload[:remote_ip] = request.remote_ip
  end
RUBY

File.write(
  "app/controllers/application_controller.rb",
  File.read("app/controllers/application_controller.rb").gsub(/^end\n/, "#{append_info_to_payload}end\n")
)

# rack-revision_route
# --------------------
initializer "rack-revision_route.rb", File.read(template_path + "rack-revision_route.rb")
gem "rack-revision_route", git: "https://github.com/labocho/rack-revision_route.git"

# rspec
# --------------------
gem_group :development, :test do
  gem "rspec-rails"
end

run "bundle install"
generate "rspec:install"

# rubocop
# --------------------
gem_group :development, :test do
  gem "rubocop"
end
file ".rubocop.yml", URI.open("https://gist.githubusercontent.com/labocho/b192ba9393c43d0f0c038c5403697e8f/raw/.rubocop.yml", &:read)

# devise
# --------------------
if yes? "Do you use devise?"
  gem "devise"

  run "bundle install"
  generate "devise:install"
end

# carrierwave
# --------------------
if yes? "Do you use carrierwave?"
  gem "carrierwave"
  if yes? "mini_magick too?"
    gem "mini_magick"
  end
end

# mail
# --------------------
if yes? "Do you use mail?"
  gem "action_mailer_config", git: "https://github.com/labocho/action_mailer_config.git" # ActionMailer の設定を mail.yml で
  initializer "action_mailer_config.rb", File.read(template_path + "action_mailer_config.rb")

  gem "exception_notification" # 例外をメールで通知
  initializer "exception_notification.rb", File.read(template_path + "exception_notification.rb")
  puts <<-EOS
============================================================
Please edit config/initializers/exception_notification.rb
============================================================
EOS
end

run "bundle install"

# Vite
# ====================
if yes? "Do you use Vite?"
  file(
    "package.json",
    <<~JSON
      {
        "scripts": {
          "build": "rm -rf public/packs && vue-tsc --noEmit && vite build",
          "watch": "vite",
          "tsc-watch": "vue-tsc --noEmit --watch"
        }
      }
    JSON
  )
  file "vite.config.js", File.read(template_path + "vite.config.js")
  file "app/helpers/vite_helper.rb", File.read(template_path + "vite_helper.rb")

  file "app/javascript/packs/application.js", "console.log('Hello, Vite!');"
  file "app/javascript/images/index.js", "// Please import images not used in other files"

  application "config.use_vite_server = false"
  environment <<~RUBY, env: "development"
    # USE_VITE_SERVER=0 bin/rails s で起動すると vite サーバを使わず public/packs を参照する
    # 事前に yarn run vite build 実行しておく
    config.use_vite_server = ENV.fetch("USE_VITE_SERVER", "1") == "1"
  RUBY

  run "yarn add --dev vite @vitejs/plugin-vue typescript vue-tsc sass pug"
  run "yarn add vue"
  run "yarn run tsc --init"

  warn "Please edit tsconfig.json: https://zenn.dev/labocho/books/270173d74fcd77/viewer/dcea12"
end

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

# template
# ====================
# haml のテンプレートをコピー
directory(template_path + "generators", "lib/generators")

# git
# ====================
git :init
