class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy] #=> ログイン状態でなければ、更新できないようにする。
  #=> beforeフィルターは、アクションを呼び出す前に、メソッドを呼び出す、という機能なので、このようにcontroller内で書く。:logged_in_userは、
  # そのcontroller内で実装されるbeforeフィルターの中で呼び出されるメソッドだから、controllerの外でで呼び出さないのであれば、privateメソッドにする。
  #=> メソッドを呼び出す時、rubyでは慣習的にシンボルにする（「メソッド参照」という）。メソッド名では、ハイフンではなく、アンダーバーを使う理由は、
  # このようにシンボルで呼び出す時に、ハイフンかマイナスか区別されなくなってしまうからである。
  #=> また、ログイン状態でなければ、editが呼び出されないので、updateを呼び出すボタンも出てこないから、:update は必要ない、とはならない。
  # ブラウザ上でPATCHリクエストが投げられなくとも、curlコマンドを立ち上げれば、そこから直接PATCHリクエストを投げることは可能。
  # このコードを使えば、真偽値について、ちゃんとしっかり考え直すテストが必要になる。このbeforeフィルターが無ければ、クリティカルな操作
  # （ログインしていないユーザーがユーザー情報を更新する操作）をユーザーに許してしまうので、しっかりと検知するテストが必要である。
  
  before_action :correct_user,   only: [:edit, :update]
  #=> beforeフィルターは、順不同ではない。edit,update アクションにアクセスしようとした時、current_user が、ログインしていて、かつ、正しいユーザーである、
  # という処理になる。correct_userメソッドでは、loggeed_in_userメソッドを処理した後に呼び出されるので、current_user のnilチェックをしなくて済む。
  # 前提を積み重ねることによって、条件分岐の工程を踏んでいない。
  
  before_action :admin_user,     only: :destroy
  
  def index
     @users = User.paginate(page: params[:page])
  end
  
  def show
     @user = User.find(params[:id])
  end
  
  def new
    @user = User.new
    # => @userは、form_forの引数に使う。中身はすべてnilだが、型情報のようにして使う。
  end
  
  def create
    # @user = User.new(user_params)  => セキュリティに問題がある。
    @user = User.new(user_params)    
    
    # @user=User.new
    #  @user.name=params[:user][:name]
    #  @user.email=params[:user][:email]
    #  @user.password=params[:user][:password]
    #  @user.password_confirmation=params[:user][:password_confirmation]
    # @user.save
    #　　User.new(name: ... ,email: ... ,) オプション引数で、必要な情報を直接与えているわけだが、ハッシュの集合体になっているので、 params[:user]と
    #　データ構造が同じ。@user = User.new(params[:user])で済む。たまたま簡単に書けるようになっているのではなく、こうなるように、
    #　form_forやモデルのカラムのデータ構造が設計されている。
    #  currencies = {japan: 'yen' , us: 'doller' , india: 'rupee'}  インドの通貨を取得するコードは、currencies[:india] => 'rupee' となるので、
    #  params={user: {name:... , email:... , password... , ...}}というデータ構造なので、名前を取得するコードは、params[:user][:name]　になる。
    #  配列の取得と形は同じ。　a=[1,2,3]  a[0] => 1
    
    
    if @user.save 
      # =>.saveでUserのvalidatesが実行され、バリデーションの戻り値は、通ればそのオブジェクトが、通らなければfaulseが返ってくる。
      # ruby では、if文の条件式では、nilとfalse以外は、trueとして評価されるので、@user.save   if @user.save == faulse を一行で書ける。
      # 保存の成功をここで扱う。
      flash[:success] = "Welcome to the Sample App!"  #=> flash[:success] は、実体はメソッドだが、特殊な変数として考えればわかりやすい。
      redirect_to @user
      #     redirect_to "/users/#{@user.id}"  redirect_to は、GETリクエストを投げる、render はテンプレートを呼び出す。
      # =>  redirect_to "user_path(@user.id)"  普通は、名前付きルートにする。変数のように扱われるが実体はメソッドで、:idのようにurlにパラメーターをとる場合、
      #                                        引数を取る。引数が、"/users/:id"の、:idの部分に入る。
      # =>  redirect_to "user_path(@user)"  名前付きルートのデフォルトで、引数にオブジェクトが入ると、そのオブジェクトのidが入る。
      # =>  redirect_to @user  redirect_to のデフォルトで、"user_path(@user)"になる。
      log_in @user
     
    else
      render 'new'
    end
  end
  
  #=> GET /users/:id/edit
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id]) 
    if @user.update_attributes(user_params) #=> 必要な情報だけ更新する、というsql文が発行されるので、User.new と、@user.save で更新するよりも、
                                            # 少しだけパフォーマンスがよい。update_attributes は、このためにrails が用意しているメソッド。
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  private #=> このコードを宣言させておくと、以降のメソッドは全てprivateメソッドになるという独特の振る舞いをみせ、、このコントローラー内でしかアクセス
          # できなくなる。ruby は、クラスもメソッドも上書きできる言語なので、rails の外側でuser_params を上書きして、セキュリティホールを作ることもできる。
          # user_params は、アスアサイメント脆弱性を解決するメソッドであり、ユーザーから送られてきたパラメーターを精査するメソッドなので、
          # 基本的にこのメソッドは上書きしたくない。慣習的に、user_params はprivateメソッドにされる。
  
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
  #  params　は、ユーザーが情報を入力するものであり、サーバー側と情報を共有する部分なので、受け取る情報を限定しないとセキュリティが脅かされる。
  #  params[:user][:admin]=trueにして管理者を装うなど。params.requireで、これを制限できる。
  #  createアクションの中の、@user = User.new(params[:user])　このままでcreateアクションを動かすと、ActiveAttributesError、というエラー文がでてしまう。
  #  これは、「コードもアイディアも正しいが、paramsの制限上にセキュリティの問題がある」、という意味。（昔のrailsでは、エラーしない仕様になっていた。）
  #  エラーを解決するためには、@user = User.new(params[:user])　の、params[:user]の部分を、params.require(:user).permit(:name, :email, :password,
  # :password_confirmation)に書き換えるが、長くなり過ぎるので、user_paramsに代入している。
  
    # beforeアクション

    # ログイン済みユーザーかどうか確認
    def logged_in_user #=> このメソッドも、このコントローラー内でしか使わないので、privateメソッドにした。
      unless logged_in? #=> unless は、if not を意味する。
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
    #=> ログインしていない状態で、edit,update が呼び出されるケースは、直接リクエストを送る場合が考えられる。しかし他に、edit の呼び出しに関しては、
    # ブラウザのヘッダーのSettingはログイン状態でなければ存在しないが、元々ログインしていたのに、たまたまsessionやcookie が切れてしまっていて、
    # ログインしていないのに、Setting　が表示されているケース起こり得る。
    
    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
      #=> もし、beforeフィルターのlogged_in_userが先に処理されない場合、current_user がnil で、@user もnil([:id]をデタラメにする) の場合、true になってしまう。
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end
