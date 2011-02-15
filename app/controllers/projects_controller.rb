class ProjectsController < ApplicationController

  def show
    @project        = Project.find(params[:id]) if params[:id]    
    @tasks          = @project.tasks
    @from_date      = Date.current.advance(:days => -7)
    @tasks_by_dates = Task.by_dates_from @project.tasks, @from_date
    @total_duration = Task.duration_from @project.tasks, @from_date
  end

end