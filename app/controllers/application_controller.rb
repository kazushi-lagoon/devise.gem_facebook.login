class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  # helper　メソッドの元々の使い方は、。gravatar_forやfull_titleがそうだったように、viewで使うもの。デフォルトでview で使える。
  # controller　で使う場合は、include で読み込んで、使えるスコープを広げる必要がある。
  
  def hello
    render html: "hello, world!"
  end
end
