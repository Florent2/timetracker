Fabricator(:project) do
  name "Project Name"
end

Fabricator(:session) do
  task!
  start { DateTime.current }
end

Fabricator(:task) do
  name "Task Name"
  project!
end