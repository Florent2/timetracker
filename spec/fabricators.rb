Fabricator(:project) do
  name "Project Name"
end

Fabricator(:task) do
  name "Task Name"
  project!
end
