module UsersHelper

  # 渡されたユーザーのGravatar画像を返す
  def gravatar_for(user, size: 80 ) #=> この書き方で、オプション引数の:size、（デフォルト値が80） がわたせるようになっている。
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end