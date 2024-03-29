module SessionsHelper
  
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember #=> remember_token の発行と、そのハッシュ値をデータベースに保存。
    cookies.permanent.signed[:user_id] = user.id #=> ブラウザの仕様上、cookies メソッドは、.permanentのような、期間を指定するメソッドを必要とする。
                                                 # 面倒であれば、とりあえず.permanentで、20年間という長期の有効期間を設定しておけばよい。
                                                 # セキュリティ上、.signed で、user_id を暗号化しておく。
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  # remember の対となる、逆の処理をすればよい。
  
  # 渡されたユーザーがログイン済みユーザーであればtrueを返す
  def current_user?(user)
    user == current_user
  end
  
  def current_user
    # @current_user ||= User.find_by(id: session[:user_id])  => 有効期限中は永続するセッション情報から、現在ログインしているユーザーオブジェクトを取り出す。
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
    
    if user_id = session[:user_id] #=> user_id = session[:user_id] と、if user_id を一行で処理できる。
      @current_user ||= User.find_by(id: user_id)
    elsif user_id = cookies.signed[:user_id] #=> session はログイン状態に関する情報で、cookies は自動でログインするための、password に代わるものである。
      #raise
      #=> raise は、問答無用で、例外を発生させるメソッドで、テストで網羅されているのか知りたい箇所に置くことで、それを知ることができる。
      # 網羅されていれば例外が発生するので、エラーが起こるはずで、パスしてしまうと、網羅されていないということになる。
      # しかし、これは原始的な方法で、コードのテストが何%網羅されているかチェックできるサービス（有料）が存在する。
      user = User.find_by(id: user_id)       # elsif なので、session が切れていなければ、という意味になる。つまり、前回のログインから一度ブラウザを
                                             # 落としていたら、という意味。
      if user && user.authenticated?(cookies[:remember_token]) #=> params[:session][:password] に代わるもので、cookies はブラウザが永続的に保持している
        log_in user                                            # ものなので、ここでも呼び出せる。
        @current_user = user
      end
    end
    #=> current_user は、_header.html.erb で呼び出されるので、呼び出され続ける。@current_user ||= User.find_by(id: user_id) で、パフォーマンス改善
    # しているということは、おそらく@current_user は、次にリクエストが発行されても、消失せずに残存している。controller でインスタンス変数を生成した
    #場合は、そのアクションで呼び出されるview のみで適用できたから分かりやすかったが、今回の場合はhelper でインスタンス変数を生成しているので、
    #ややこしい。なので、@current_user は残存しているので、log_out メソッドでは、@current_user=nil で処理する必要がある。
    
  end
  
  def logged_in?
    !current_user.nil?
    #=> ! で、true,false の結果が逆転する。
  end
  
  def log_out
    forget(current_user)
    session.delete(:user_id) #=> .delete メソッドは、rails guides の、action controller から参照。
    @current_user = nil
  end
  
  # 記憶したURL (もしくはデフォルト値) にリダイレクト
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default) #=> 論理和の処理で、session[:forwarding_url]　がnil だった時、default のurl へリダイレクトさせたい。
    session.delete(:forwarding_url) #=> 消しておかないと、次回もログインすると、もプロフィールページではなく、editページへ飛んでしまう。
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
  #=> リクエストフォワーディングでは、リクエストしたurlを一時的に保存させて、適切な箇所でそこへリダイレクトさせたい。
  # 「一時的に」なので、sessionで情報を持たせるのが適切。
  # request は特殊な変数で、ユーザーが発行したリクエストのいろいろな情報を持つ。.original_url で、ユーザーが元々行きたかったurl になる。
  # if request.get? で、ここでは、updateアクションのbeforeフィルターでは、この処理を行わないようにする。beforeフィルターが発動するのは、
  # GET /users/:id/edit,  PATCH /users/:id なので、ログインしていない状態で後者のリクエストを送ると、/users/:id がsession に記憶され、
  # それからログインすると、redirect_toメソッドによって、GET /users/:id で、showアクションになってしまうからである。それなら、
  # フレンドリーフォワーディングに関しては（updateアクションに関しては、ログインしていない状態でのアクセスを防げていればよい）、
  # editにのみ適用されればよいので、updateでは処理しないようにする。
  
end
