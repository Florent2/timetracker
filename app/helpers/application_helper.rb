module ApplicationHelper

  def archive_link(task, options={})
    options.reverse_merge! :method => :put, :class => "archive action", :title => "archive", :name => "archive"
    add_access_key_to_title options
    link_to options[:name], task_archive_path(task), options
  end
  
  def interrupt_link(task, options={})
    options.reverse_merge! :method => :put, :class => "interrupt action", :title => "interrupt", :name => "interrupt", :accesskey => "i"
    add_access_key_to_title options    
    link_to options[:name], task_interrupt_path(task), options
  end

  def resume_link(task, options={})
    options.reverse_merge! :method => :put, :class => "resume action", :title => "resume", :name => "resume", :accesskey => "r"    
    add_access_key_to_title options    
    link_to options[:name], task_resume_path(task), options
  end
  
  def status_span(task)
    content_tag :span, task.status, :class => task.status
  end

  def add_access_key_to_title(options)
    options[:title] += " (#{options[:accesskey]})" if options[:accesskey]
  end
  
end
