Rails.application.routes.draw do
  resources :events
  resources :venues
  root to: 'pages#home'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'create_all', to: 'venues#create_all'

end


