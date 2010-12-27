Playtime::Application.routes.draw do
  resource :account, :controller => "jesters"
  resources :jesters do
    resources :data, :singular => :point
  end

  resource :availability, :controller => :availability
  resources :shows
  
  get "login" => "jester_sessions#new", :as => :login
  post "login" => "jester_sessions#create"
  get "logout" => "jester_sessions#destroy", :as => :logout
  resource :session, :controller => "jester_sessions"

  root :to => "jesters#index"
end
