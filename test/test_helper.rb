ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  def is_logged_in?
    !session[:user_id].nil?
  end
  
  # テストユーザーとしてログインする
  def log_in_as(user)
    session[:user_id] = user.id
  end
  
end

class ActionDispatch::IntegrationTest

  # テストユーザーとしてログインする
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: { session: { email: user.email,
                                          password: password,
                                          remember_me: remember_me } }
  end
  #=> こちらは、統合テストでの、ユーザーをログインさせるhelperメソッド。こちらは統合テストで、ブラウザ上でできることがシミュレートできるものなので、
  # login_path にpost リクエストを送るというやり方で、単体テストでのsession に情報を直接持たせる方法と、やり方が異なる。しかし、ログインさせるという、
  # やりたい事は同じなので、同じメソッド名にすることで、単体テストでも統合テストでもどちらでも同じ名前で、やりたい事が実現できるようにして、
  # 使い勝手をよくしている。
  #=> log_in_as(user, password: 'password', remember_me: '1') メソッドの定義という文脈の中で、オプション引数のフォーマットを利用すると、
  # デフォルト値の設定になる。オプション引数のハッシュのデータ構造体とは違った意味合いを持つ。
  # なので、password: password,のように、シンボルとしてではなく、変数（password）のようにして渡している。
  # 使われている文脈によって振る舞いが変わる、典型的なものである。

end
