Fabricator(:project) do
  name "Project Name"
end

Fabricator(:task) do
  name "Task Name"
  project!
end

Fabricator(:session) do
  task!
  start { DateTime.current }
end

Fabricator(:running_task, :from => :task) do
  after_create { |task| task.sessions << Fabricate(:session, :task => task, :finish => nil) }
end