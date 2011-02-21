class SessionsController < ApplicationController
  before_filter :find_session
  before_filter :session_cant_be_running

  def edit
  end
  
  def update
    if @session.update_attributes(params[:session])
      redirect_to @session.task, :notice => 'Session was successfully updated'
    else
      render :action => "edit"
    end    
  end
  
  def destroy
    @session.destroy
    redirect_to :back, :notice => "Session successfully destroyed"
  end

  private
  
  def find_session
    @session = Session.find(params[:id]) if params[:id]
  end
  
  def session_cant_be_running
    redirect_to :back, :alert => "Action prohibited for a running session" if @session.running?
  end
  
end