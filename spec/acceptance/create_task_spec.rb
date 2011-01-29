require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Create Task", %q{
  In order to track spent time
  As a developer
  I want to register tasks
} do

  scenario "Task Creation With A New Project" do
    visit "/tasks/new"
    fill_in "task[name]", :with => "Setup Application"
    fill_in "task[project_name]", :with => "Grocery List"
    click_button "Create Task" 
    page.should have_content("Setup Application")
    page.should have_content("Grocery List")
  end

  scenario "Task Creation With An Existing Project" do
    Fabricate :project, :name => "Grocery List"
    Fabricate :project, :name => "Music Maker"
    visit "/tasks/new"
    fill_in "task[name]", :with => "Setup Application"
    select "Grocery List", :from => "task[project_id]"
    click_button "Create Task" 
    page.should have_content("Setup Application")
    page.should have_content("Grocery List")
  end
  
  scenario "Missing Name" do
    visit "/tasks/new"
    fill_in "task[project_name]", :with => "Grocery List"
    click_button "Create Task" 
    page.should have_content("Name can't be blank")    
    Task.count.should be_zero
  end
  
end
