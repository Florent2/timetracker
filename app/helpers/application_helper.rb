module ApplicationHelper
  
  def interrupt_link(task, options={})
    options.reverse_merge! :method => :put
    link_to "interrupt", task_interrupt_path(task), options
  end

  def resume_link(task, options={})
    options.reverse_merge! :method => :put    
    link_to "resume", task_resume_path(task), options
  end

end
