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
  # 　セキュアなパスワードの実装は、railsのメソッドであるhas_secure_passwordを使えば、簡単に完了してしまう。ただし、このメソッドを使うためには、
  # レールを用意してあげる必要があって、それがusersに対するpassword_digestカラムの追加と、bcryptというgemのインストール。
  # 　usersテーブルにnameカラムが存在すると、u.name="kazushi" u.save　で、nameカラムに保存できるが、has_secure_passwordでは、passwordカラムが
  # 存在しないのに、u.password="pass" ができて、u.saveとすると、password_digestカラムにbcryptでハッシュ化された値が保存される。
  
  validates :password, presence: true, length: { minimum: 6 }
                    
  # ActiveRecordの継承によって、saveやcreateなどのメソッドが使えるようになったのに加えて、validatesメソッドも使えるようになった。
  # このメソッドに対して、オプション引数（link_toメソッドで出た概念）を投げている形なので、presence:...,length:...　という形で、後ろからバンバンバンバン
  # 投げていく。validatesはいろいろなオプションが初めから用意されているパッケージ製品のようなもので、使いたいものを（今回でいうところの、presenceやlength
  # など）オプション引数として、投げていく。
  
  
  
end
