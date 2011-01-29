class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :get_projects
  
  private
  
  def get_projects
    @projects = Project.recents_first
  end
end
