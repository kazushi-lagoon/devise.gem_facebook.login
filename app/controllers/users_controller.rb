class UsersController < ApplicationController
  
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
     
    else
      render 'new'
    end
  end
  
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

end
