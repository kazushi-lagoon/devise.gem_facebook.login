# raise を置いた部分のコードを網羅させたい。つまり、session[:user_id]==nil かつ、でも永続cookie によってちゃんと自動ログインできるテストと、
# ちゃんとできないテスト。setup での@user は、session はnil で、cookie はremember(@user)　によって、持っている。

require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)
    remember(@user)
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do #=> remember_digest の照合で失敗させると、ちゃんとcurrent_userがnilになるか、のテスト。
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
  
end