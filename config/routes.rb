Timetracker::Application.routes.draw do
  resources :projects 
    
  resources :tasks do
    put :archive
    put :interrupt
    put :resume
  end

  resources :sessions, :only => [:edit, :update, :destroy] 
  
  root :to => "tasks#index"
end
