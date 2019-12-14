Rails.application.routes.draw do
  
  get 'users/new'

  root 'static_pages#home'
  # => get '/' , to: 'static_pages#home'
  # => root_path
  
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  
  # get 'static_pages/contact' の書き方（urlと、それに対応するコントローラー・アクションを一体化させた書き方）だと、
  # 名前付きルートが、static_pages_contact_path　となって長くなってしまう。
  # get  '/contact', to: 'static_pages#contact' この書き方で、名前付きルートの、contact_path　が追加される。
  
  get '/signup', to: 'users#new'
  
  resources :users
  # rails routes で、一番左のPrefixのところは、最後に_pathを付けると、名前付きルートになる。

  root 'application#hello'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
