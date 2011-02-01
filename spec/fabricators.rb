Fabricator(:project) do
  name { Fabricate.sequence(:name) { |i| "Project ##{i}" } }
end

Fabricator(:task) do
  name { Fabricate.sequence(:name) { |i| "Task ##{i}" } }
  project!
end

Fabricator(:session) do
  task!
  start { DateTime.current }
end

Fabricator(:running_task, :from => :task) do
  after_create { |task| task.sessions << Fabricate(:session, :task => task, :finish => nil) }
end

Fabricator(:interrupted_task, :from => :task) do
  after_create { |task| task.sessions << Fabricate(:session, :task => task, :start => DateTime.current.advance(:hours => -1), :finish => DateTime.current) }
end