Playtime::Application.routes.draw do
  resource :account, :controller => "jesters"
  resources :jesters do
    resources :data, :singular => :point
  end

  get "availability(/:year/:month/:day)" => "availability#show", :as => :availability
  put "availability(/:year/:month/:day)" => "availability#update"
  
  get "shows(/:year/:month)" => "shows#index", :as => :shows
  get "shows/:year/:month/:day" => "shows#show", :as => :show
  get "shows/:year/:month/:day/edit" => "shows#edit", :as => :edit_show
  put "shows/:year/:month/:day" => "shows#update"
  
  scope :as => :show, :path => "shows/:year/:month/:day" do
    resources :notes
  end
  
  get "login" => "jester_sessions#new", :as => :login
  post "login" => "jester_sessions#create"
  get "logout" => "jester_sessions#destroy", :as => :logout
  resource :session, :controller => "jester_sessions"

  root :to => "jesters#index"
end
