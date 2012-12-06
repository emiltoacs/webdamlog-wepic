WepimApp::Application.routes.draw do

  if ENV['USERNAME']=='MANAGER'
    root :to => 'welcome#index'
    match 'welcome/login' => 'welcome#login'
    match "welcome/shutdown/:id" => "welcome#shutdown"
    match 'welcome/start/:id' => "welcome#start"
    match 'welcome' => 'welcome#index'    
    match '/*else' => 'welcome#index'
  else
    root :to => 'users#index'
    match 'program' => 'program#index', :as => :program
    match 'wepic' => 'wepic#index', :as => :wepic
    resources :pictures do
      member do
        get :images
      end
    end
    resources :query
    match 'query/insert' => 'query#insert'
  end
    resources :users, :user_sessions
    match 'login' => 'user_sessions#new', :as => :login
    match 'logout' => 'user_sessions#destroy', :as => :logout
    match 'list' => 'users#list'    
  match 'admin' => 'admin#index', :as => :admin

  # The priority is based upon order of creation:
  # first created -> highest priority.
end
