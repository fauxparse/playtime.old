Playtime::Application.routes.draw do
  resource :account, :controller => "jesters"
  resources :jesters
    
  get "login" => "jester_sessions#new", :as => :login
  post "login" => "jester_sessions#create"
  get "logout" => "jester_sessions#destroy", :as => :logout
  resource :session, :controller => "jester_sessions"

  root :to => "jester_sessions#new"
end
