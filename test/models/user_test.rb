require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com" ,password: "foobar", password_confirmation: "foobar")
  end
  # setupメソッドは、以降のtest do end の中の頭で実行されるようになっているので、
  # そのそれぞれの中で@userが使える。


  test "should be valid" do
    assert @user.valid?
    # => 「バリデーションが通る」という意味。
  end
  
  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
    # => 「バリデーションが通らない」という意味。
  end
  
  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  # 二つのテストが合わさって、一つのバリデーション（フォーマット）のクオリティが担保される。このファイルはモデルのテストであり、.validで、データベース
  # に保存する時、バリデーションが期待通りに働いているかをテストしている。間違ってそうで正しいアドレスと、正しそうで間違っているアドレスで、
  # それぞれ期待通りのバリデートになっているかをテストして、正規表現のクオリティをみている。これでも、100%のクオリティの正規表現ではないが、
  # 80%くらいは担保される。正規表現によるフィルターが緩過ぎると下のテストが落ちるし、厳しくし過ぎると上のテストが落ちるといった具合に、フィルターの強さ
  # 加減の調整を迫られる。"#{valid_address.inspect} should be valid"で、引数で渡している理由は、どのサンプルのアドレスでテストが落ちたかを分かるよう
  # にして、デバッグしやすくするため。この引数がないと、タイトルの"email validation should accept valid addresses"が落ちました、という情報
  # がでるだけで、どのアドレスが落ちたのか分からない。
  
  test "email addresses should be unique" do
    duplicate_user = @user.dup  #=> .dupで、同じ属性を持つデータの複製を生成する。
    duplicate_user.email = @user.email.upcase
    @user.save  #=> 一意性を持たせるテストなので、一度データベースに保存する。
    assert_not duplicate_user.valid?
  end
  
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?('')
  end
  
end


