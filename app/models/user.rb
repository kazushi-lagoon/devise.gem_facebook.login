class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable
  attr_accessor :remember_token
  #=> 仮想的属性を与える。仮想的属性の生存期間は、次のリクエストが発行されるまで。コンソール上では、exit するまで。
  # 仮想的属性は、一時的にオブジェクトに値を持たせるが、データベースには反映させない情報。今回は、この情報が消失するまでに、ユーザーのクッキーに
  # 保存し、ハッシュ化させた値をデータベースに保存したい。
  # password の時は、has_secure_password で自動的に実装されたが、今回は自分で実装する必要がある。
  # 実体は、以下の二つのメソッドの実装。セッターとゲッターという。
  # def remember_token=(token)
  #   @remember = token
  # end
  # def remember_token
  #   @remember
  # end
  
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }  # =>オプション引数の中のオプション引数。
                    # uniquenessのデフォルトでは、大文字・小文字を区別してしまう。
  # 通常、アドレスは大文字・小文字を区別せずに送信されるので、case_sensitive: false　で、大文字・小文字を区別せずに一意性を持たせる。
  
  # 保護すべき情報はbcryptなどのハッシュ関数を使って、不可逆的にハッシュ化させた値をデータベースに保存する。こうすることで、データベース
  # をクラックされても、元の値は分からない。このアプローチはrailsに限らない。
  # 　セキュアなパスワードの実装は、railsのメソッドであるhas_secure_passwordを使えば、簡単に完了してしまう。
  #  「セキュアに実装する」というのは、すごく難しいことなのだが（csrf対策、データベースにはハッシュ化された値を保存するなど、セキュリティの勉強が必要）、
  # そのレールがhas_secure_passwordですでに用意されている。
  #  ただし、このメソッドを使うために、こちらが用意する必要のあるものがあって、それがusersに対するpassword_digestカラムの追加と、
  # bcryptというgemのインストールである。
  # 　usersテーブルにnameカラムが存在すると、u.name="kazushi" u.save　で、nameカラムに保存できるが、has_secure_passwordでは、passwordカラムが
  # 存在しないのに、u.password="pass" ができて、u.saveとすると、password_digestカラムにbcryptでハッシュ化された値が保存される。
  
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  #=> allow_nilオプションによって、ユーザー情報の更新時に、わざわざまたパスワードを入力することを強制する、という状態を解決している。
                    
  # ActiveRecordの継承によって、saveやcreateなどのメソッドが使えるようになったのに加えて、validatesメソッドも使えるようになった。
  # このメソッドに対して、オプション引数（link_toメソッドで出た概念）を投げている形なので、presence:...,length:...　という形で、後ろからバンバンバンバン
  # 投げていく。validatesはいろいろなオプションが初めから用意されているパッケージ製品のようなもので、使いたいものを（今回でいうところの、presenceやlength
  # など）オプション引数として、投げていく。
  
  # 渡された文字列のハッシュ値を返す
  def User.digest(string) #=> 書く場所は、helperでもcontrollerでも問題ないが、ユーザーに関するものなので、ここに書いた。
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost) #=> BCryptのドキュメントから、与えられた引数をハッシュ化させるコード。また、costオプションでは、
                                                # 本来はハッシュ化させることにはコストがかかるが、テストにおけるパスワードは漏洩しても特に問題ない
                                                # ので、本番ではちゃんとハッシュ化させて、テストでは簡易的にハッシュ化させるということをさせている。
                                                # ?は三項演算子というもの。
  end
  # def digest(string)ではなく、def User.digest(string) なのは、インスタンスメソッドではなく、クラスメソッドだから。インスタンスメソッドは、
  #インスタンスに対してしか使えないので、わざわざインスタンスを生成しなくても使用できるメソッドは、全てクラスメソッドにする。クラスメソッドに
  #してしまうと、呼び出す時にわざわざインスタンスを生成しなくてはならなくなる。
  # ダブルコロン（::）は、rubyの世界における、ディレクトリの階層の区分け（/）のようなものとして捉えるとよい。
  
  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
    #=> 標準gemで、デフォルトで用意されているモジュール（SecureRandom）とメソッド（urlsafe_base64）で、セキュアでランダムな文字列を生成する時によく使う。
    # 「トークン」とは、パスワードと同様に秘密情報であるが、パスワードはユーザーが管理する情報であるのに対し、トークンはコンピューターが管理する情報
    # である。トークンはコンピューター同士がやりとりするものなので、無作為なものでよい。
  end
  
  def remember #=> remember me のチェックボックスをチェックした時に、呼び出されるメソッド。
    self.remember_token = User.new_token #=> self を省略してしまうと、remember_token がローカル変数として評価されてしまうので、省略不可。
                                         # update_attribute は、メソッドなので、省略可能。helper メソッドとは異なり、ここに書かれているのは全て
                                         # インスタンスメソッドなので、self. はわざわざ書かなくてもあることが自明。
    self.update_attribute(:remember_digest, User.digest(remember_token))
    # update_attribute は、バリデーションをスキップさせてデータベースに保存するメソッド。ユーザーさんが何を入力するか分からない
    # から、バリデーションをかける必要があった。今回のように、自分で発行したものを、自分で保存するケースでは、その必要がない。
  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    self.update_attribute(:remember_digest, nil)
  end
  
  def authenticate(unencrypted_password)
        BCrypt::Password.new(self.password_digest).is_password?(unencrypted_password)
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil? #=> 二つの異なる種類のブラウザ（ここではChromeとFirefoxとする）で、同時にこのアプリを立ち上げ、
                                         # Chromeでログアウトしてから、一度Firefoxのブラウザを落として、もう一度Firefoxでこのアプリにアクセスすると、
                                         # Chromeのログアウトによってremember_digest がnil になっていて、Firefoxでアクセスした時に、Firefoxでcookie
                                         # は残っているので、このauthenticated?メソッドが発動されて、remember_digest がnil のためBCrypt で例外エラー
                                         # が起きてしまう。BCrypt の処理では、remember_digest のところにnil が入ると、nil やfalse を返してくれるの
                                         # ではなく、エラーを発生させてしまうのである。なので、この行の処理で、このケースのとき、false を返して
                                         # 処理を止まらせる。return false if は便利な処理で、if文に該当する場合は、false という結果で終わらせて、
                                         # 以降の処理は実行させない、ということができる。この種類のバグは、cookie が残っていたら、remember_digestも
                                         # あるはずだという、誤った考えから生まれる。上でみてきたように、cookie が残っているのに、remember_digestが
                                         # 消失している場合もあり得る。
    BCrypt::Password.new(self.remember_digest).is_password?(remember_token)
  end
  
  def self.find_for_oauth(auth)
    user = User.where(uid: auth.uid, provider: auth.provider).first

    unless user
      user = User.create(
        uid:      auth.uid,
        provider: auth.provider,
        email:    auth.info.email,
        name:  auth.info.name,
        password: Devise.friendly_token[0, 20],
        image:  auth.info.image
      )
    end

    user
  end
  
end
