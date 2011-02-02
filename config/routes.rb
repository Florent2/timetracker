Timetracker2::Application.routes.draw do
  resources :tasks do
    put :archive
    put :interrupt
    put :resume
  end
  
  resources :projects 
  
  root :to => "tasks#index"
end
