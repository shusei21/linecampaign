Rails.application.routes.draw do
  devise_for :admins
  root 'home#top'
  get '/index' => 'home#index'
  get '/richmenu/index' => 'richmenu#index'
  post '/richmenu/create' => 'richmenu#create'
  post '/reset_campaign' => 'home#reset_campaign'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/recieve' => 'webhook#recieve'
  post '/callback' => 'webhook#callback'
end
