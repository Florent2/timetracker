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
    click_button "Save" 
    page.should have_content("Setup Application")
    page.should have_content("Grocery List")
  end

  scenario "Task Creation With An Existing Project" do
    Fabricate :project, :name => "Grocery List"
    Fabricate :project, :name => "Music Maker"
    visit "/tasks/new"
    fill_in "task[name]", :with => "Setup Application"
    select "Grocery List", :from => "task[project_id]"
    click_button "Save" 
    page.should have_content("Setup Application")
    page.should have_content("Grocery List")
  end
  
  scenario "Task Creation With New Project And Existing Project Selected: It Picks Up The New Project" do
    Fabricate :project, :name => "Grocery List"
    Fabricate :project, :name => "Music Maker"
    visit "/tasks/new"
    fill_in "task[name]", :with => "Setup Application"
    fill_in "task[project_name]", :with => "Astronomy Wizard"    
    select "Grocery List", :from => "task[project_id]"
    click_button "Save" 
    page.should have_content("Setup Application")
    page.should have_content("Astronomy Wizard")    
  end
  
  scenario "Missing Name Cause An Error" do
    visit "/tasks/new"
    fill_in "task[project_name]", :with => "Grocery List"
    click_button "Save" 
    page.should have_content("Name can't be blank")    
    Task.count.should be_zero
  end
  
  scenario "Default Start Time Should Be Now" do
    visit "/tasks/new"
    fill_in "task[name]", :with => "Setup Application"
    fill_in "task[project_name]", :with => "Grocery List"
    click_button "Save"     
    Task.last.sessions.first.start.hour == DateTime.current.hour # have to restrict to hour because else failed due to difference between seconds
  end
  
  scenario "Start Time Can Be Chosen" do
    visit "/tasks/new"
    fill_in "task[name]", :with => "Setup Application"
    fill_in "task[project_name]", :with => "Grocery List"
    select "12", :from => "task[sessions_attributes][0][start(4i)]"
    select "30", :from => "task[sessions_attributes][0][start(5i)]"
    click_button "Save"         
    Task.last.sessions.first.start.hour.should  == 12
    Task.last.sessions.first.start.min.should   == 30
  end
end
