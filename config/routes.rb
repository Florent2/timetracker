Timetracker2::Application.routes.draw do
  resources :tasks do
    put :interrupt
    put :resume
  end
  
  resources :projects 
  
  root :to => "tasks#new"
end
