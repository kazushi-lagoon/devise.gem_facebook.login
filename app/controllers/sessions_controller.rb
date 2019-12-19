class SessionsController < ApplicationController
 
  
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      #=> user &&  の部分がないと、登録されていないemailでfind_byしたとき、user=nilとなり、authenticateで、undifined methodでエラーする。
      # nil:NilClassというエラー文は、このような、オブジェクトがniになるケースが考慮できていないときに起こる、よくあるミス。
      # 　rubyに限らず、プログラミング言語の一般的なルールとして、「評価しなくていいものは評価しない。」論理積で、左から評価して、nil,falseが出た時点で、
      #その行全体の評価は決まるので、その段階で処理を止める。なので、userがnilだった場合、そこで処理が止まるので、
      #user.authenticate(params[:session][:password])の実行はされないので、エラーしない。
      # 　nilはオブジェクトなのでメッセージの受け渡しは可能だが、authenticateメソッドが定義されていない。userオブジェクトは、has_secure_passwordで
      #定義されている。
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      
      log_in user
      #=> session[:user_id]=user.id　といきなりしてもいいが、可読性を上げるために便利メソッドとして　log_in(user) を定義した。
      redirect_to user
      #=> 
    else
      # エラーメッセージを作成する
      flash.now[:danger] = 'Invalid email/password combination' # 二回目以降のGETリクエストで消えるので、renderだと、二回目のテンプレートの
                                                                #描画まで残ってしまう。.nowで、解決する。（一リクエスト分減らす。）
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
