class AddPasswordDigestToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :password_digest, :string
    # rails generate migration add_password_digest_to_users password_digest:stringとすることで、railsのパターンに従ったことによって、
    # rails が開発者のやろうとしていることわ読みとってくれて、ファイルの中のコードがすでに書き込まれた状態で、生成される。
  end
end
