module SessionsHelper
  
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end
  
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])  #=> 有効期限中は永続するセッション情報から、現在ログインしているユーザーオブジェクトを取り出す。
    #=> current_user は、link_to の引数に渡すので、view 側で使うということは、@current_user とインスタンス変数に格上げする必要がある。
    #=> セッションが切れていたら、Userモデルに該当するidが見つからず、.find_by はnil を返す。これが、.findだと、エラーになってしまう。
    #
    # def current_user
    #  @current_user = User.find_by(id: session[:user_id])
    # end  としてしまうと、毎回毎回データベースにアクセスしてしまい、パフォーマンス改善(データベースに投げるクエリの数を減らす)の観点から望ましくない。
    # 
    # def current_user
    #  if @current_user == nil
    #     @current_user = User.find_by(id: session[:user_id])
    #  else
    #     @current_user
    #  end
    # end
    #　これでパフォーマンス改善されたが、これは一行で省略できる。　||=　の形は、今回のようなパフォーマンス改善のときに頻出する形。
    #  「何かの情報（@current_user）があるのなら実行しない、ないのだったら実行する。」パフォーマンス改善したいときには、よくある話。
    #　 @current_user =  @current_user || User.find_by(id: session[:user_id])　が元の形。　a = a+1 => a += 1
    #　論理和で、論理積の反対で、左側がfalse で初めて右側が評価される。プログラミング言語の一般的なルールとして、「評価しなくていいものは評価しない。」
    #  論理和は、片方がtrueだったらもうtrue(もうそこで処理を止める)、論理積は、片方がfalseだったらもうfalse。
    #  論理値を用いて、true,false を返しているのではなく、処理（変数への代入）の場合分けを一行に省略している。
    
  end
  
  def logged_in?
    !current_user.nil?
    #=> ! で、true,false の結果が逆転する。
  end
  
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
  
end
