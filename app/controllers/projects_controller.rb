class ProjectsController < ApplicationController

  before_filter :find_project
  
  def show
    @tasks = @project.tasks
  end

  private

  def find_project
    @project = Project.find(params[:id]) if params[:id]
  end

end