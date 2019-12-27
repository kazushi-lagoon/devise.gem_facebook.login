#  index ページで、ページネーションも実装されたものを作りたい。そのためには、登録されたたくさんのユーザーが必要になるが、これを一つづつブラウザ上で
# 行うのは非常に大変。なので、faker gem を活用しながら、db:seeds で実行したいコードを用意して、rails db:seed で実行する。rails console で、
# このコードを実行しても可能だが、このように、ruby のコードとして用意しておけば、また実行したい時に簡単に実行できる。これをタスクと呼ぶ。
# 

User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true)

99.times do |n|
  name  = Faker::Name.name #=> faker gem で、このコードによって、それらしい名前がランダムで呼び出せる。
  email = "example-#{n+1}@railstutorial.org" #=>n+1 のところで、 一意性が守られ。
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end
#  .create! の、! は、これによって、バリデーションで弾かれた段階で、例外処理を発生させる。これがない場合だと、false が返ってきも、処理は続行されて、
# 無駄に時間がかかってしまう。db:seeds にはりきとうせいが無いため（マイグレーションファイルと違って）、二回連続で、rails db:seed を実行しても、
# 全く同じ処理が始まり、メールアドレスの一意性でバリデーションで弾かれるのが、100件で起こる時間を待たなければならなくなってしまう。