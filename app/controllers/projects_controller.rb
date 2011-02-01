class ProjectsController < ApplicationController

  before_filter :find_project
  
  def show
    @tasks_by_dates = Task.by_dates_from @project.tasks, Date.current.advance(:days => -7)
  end

  private

  def find_project
    @project = Project.find(params[:id]) if params[:id]
  end

end