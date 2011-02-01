class TasksController < ApplicationController
  before_filter :find_task
  
  def index
    @tasks_by_dates = Task.by_dates_from Task, Date.current.advance(:days => -7)
  end

  def show
  end

  def new
    @task = Task.new :project => Project.recents_first.first
    @task.sessions.build :start => DateTime.current    
  end

  def edit
  end

  def create
    @task = Task.new(params[:task])
    if @task.save
      redirect_to @task, :notice => 'Task was successfully created'
    else
      render :action => "new"
    end
  end

  def update
    if @task.update_attributes(params[:task])
      redirect_to @task, :notice => 'Task was successfully updated'
    else
      render :action => "edit"
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_url, :notice => "'#{@task.name}' has been successfully destroyed"
  end

# non REST actions
  
  def interrupt
    @task = Task.find params[:task_id]
    if @task.interrupt!
      redirect_to :back, :notice => "'#{@task.name}' has been interrupted"      
    else
      redirect_to :back, :alert => "'#{@task.name}' is already interrupted"
    end
  end

  def resume
    @task = Task.find params[:task_id]
    if @task.resume!
      redirect_to :back, :notice => "'#{@task.name}' has been resumeed"      
    else
      redirect_to :back, :alert => "'#{@task.name}' is already running"
    end
  end

  private
  
  def find_task
    @task = Task.find(params[:id]) if params[:id]
  end

end
