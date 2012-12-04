WepimApp::Application.routes.draw do
  
  if ENV['PORT'].to_i>9999
    root :to => 'users#index'
  else
    root :to => 'welcome#index'
    match 'welcome/new' => 'welcome#new'
    match 'welcome/existing' => 'welcome#existing'
    match "welcome/shutdown/:id" => "welcome#shutdown"
    match 'welcome/start/:id' => "welcome#start"
    match 'welcome' => 'welcome#index'    
    match '/*else' => 'welcome#index'
  end

  match 'admin' => 'admin#index', :as => :admin
  match 'program' => 'program#index', :as => :program
  match 'wepic' => 'wepic#index', :as => :wepic
  resources :pictures do
    member do
      get :images
    end
  end
  resources :query
  match 'query/insert' => 'query#insert'
  resources :users, :user_sessions
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match 'list' => 'users#list'

  # The priority is based upon order of creation:
  # first created -> highest priority.
end
