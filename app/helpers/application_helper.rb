module ApplicationHelper

  def archive_link(task, options={})
    options.reverse_merge! :method => :put, :class => "archive action", :title => "archive", :name => "archive"
    link_to options[:name], task_archive_path(task), options
  end
  
  def interrupt_link(task, options={})
    options.reverse_merge! :method => :put, :class => "interrupt action", :title => "interrupt", :name => "interrupt"
    link_to options[:name], task_interrupt_path(task), options
  end

  def resume_link(task, options={})
    options.reverse_merge! :method => :put, :class => "resume action", :title => "resume", :name => "resume"    
    link_to options[:name], task_resume_path(task), options
  end
  
  def status_span(task)
    content_tag :span, task.status, :class => task.status
  end

end
