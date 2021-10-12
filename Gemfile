source 'https://rubygems.org'

gem 'rails',        '5.1.6'
gem 'bcrypt',         '3.1.12'
gem 'faker',          '1.7.3'
gem 'will_paginate',           '3.1.6'
gem 'bootstrap-will_paginate', '1.0.0' #=>'will_pagenate'の、ナビゲーションバーに、自動でデザインをかけてくれるgem
gem 'bootstrap-sass', '3.3.7'
# gem 'bootstrap-sass', '3.3.7'　このgemで、bootstrapの公式からダウンロードする必要はない。ただしこれは使える状態にしただけなので、importする必要がある。
# gemを書き換える前の環境でサーバーが立ち上がったままになっているため、新しくgemを書き換えた場合、rails serverを立ち上げ直す必要がある。
# configや開発環境を書き換えた場合も同様で、サーバーを立ち上げた時に一回読み込んでそれを使いまわしているため、rails serverを立ち上げ直す必要がある。
# MVCは、毎回毎回ブラウザで呼び出す時に読み込み直しているので、サーバーを立ち上げ直す必要はない。
gem 'puma',         '4.3.9'
gem 'sass-rails',   '5.0.6'
gem 'uglifier',     '3.2.0'
gem 'coffee-rails', '4.2.2'
gem 'jquery-rails', '4.3.1'
gem 'turbolinks',   '5.0.1'
gem 'jbuilder',     '2.7.0'
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'dotenv-rails'

group :development, :test do
  gem 'sqlite3', '1.3.13'
  gem 'byebug',  '9.0.6', platform: :mri
end

group :development do
  gem 'web-console',           '3.5.1'
  gem 'listen',                '3.1.5'
  gem 'spring',                '2.0.2'
  gem 'spring-watcher-listen', '2.0.1'
end

group :test do
  gem 'rails-controller-testing', '1.0.2'
  gem 'minitest',                 '5.10.3'
  gem 'minitest-reporters',       '1.1.14'
  gem 'guard',                    '2.13.0'
  gem 'guard-minitest',           '2.4.4'
end

group :production do
  gem 'pg', '0.20.0'
end

# Windows環境ではtzinfo-dataというgemを含める必要があります
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]