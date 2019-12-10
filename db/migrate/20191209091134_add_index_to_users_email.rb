class AddIndexToUsersEmail < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :email, unique: true　#=> usersテーブルの、emailカラムに、indexを持たせる。オプションのunique: trueで、一意性を持たせた。
  end
end
