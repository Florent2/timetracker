class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :get_projects
  before_filter :get_running_task
  before_filter :get_interrupted_tasks
  
  private
  
  def get_interrupted_tasks
    @interrupted_tasks = Task.actives.recents_first - [@running_task]
  end
  
  def get_projects
    @projects = Project.recents_first
  end
  
  def get_running_task
    @running_task = Task.running_task    
  end
end
