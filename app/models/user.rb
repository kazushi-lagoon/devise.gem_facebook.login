class User < ApplicationRecord
  
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }  # =>オプション引数の中のオプション引数。
                    # uniquenessのデフォルトでは、大文字・小文字を区別してしまう。
  # 通常、アドレスは大文字・小文字を区別せずに送信されるので、case_sensitive: false　で、大文字・小文字を区別せずに一意性を持たせる。
  
  has_secure_password
  # 保護すべき情報はbcryptなどのハッシュ関数を使って、不可逆的にハッシュ化させた値をデータベースに保存する。こうすることで、データベース
  # をクラックされても、元の値は分からない。このアプローチはrailsに限らない。
  # 　セキュアなパスワードの実装は、railsのメソッドであるhas_secure_passwordを使えば、簡単に完了してしまう。
  #  「セキュアに実装する」というのは、すごく難しいことなのだが（csrf対策、データベースにはハッシュ化された値を保存するなど、セキュリティの勉強が必要）、
  # そのレールがhas_secure_passwordですでに用意されている。
  #  ただし、このメソッドを使うために、こちらが用意する必要のあるものがあって、それがusersに対するpassword_digestカラムの追加と、
  # bcryptというgemのインストールである。
  # 　usersテーブルにnameカラムが存在すると、u.name="kazushi" u.save　で、nameカラムに保存できるが、has_secure_passwordでは、passwordカラムが
  # 存在しないのに、u.password="pass" ができて、u.saveとすると、password_digestカラムにbcryptでハッシュ化された値が保存される。
  
  validates :password, presence: true, length: { minimum: 6 }
                    
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
  
end
