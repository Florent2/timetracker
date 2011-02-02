module ApplicationHelper

  def archive_link(task, options={})
    options.reverse_merge! :method => :put
    link_to "archive", task_archive_path(task), options
  end
  
  def interrupt_link(task, options={})
    options.reverse_merge! :method => :put
    link_to "interrupt", task_interrupt_path(task), options
  end

  def resume_link(task, options={})
    options.reverse_merge! :method => :put    
    link_to "resume", task_resume_path(task), options
  end

end
