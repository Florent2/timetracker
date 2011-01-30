require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Interrupt Task", %q{
  In order to switch to other task or take a deserverd break
  As a developer
  I want to interrupt the current ask
} do

  scenario "Task Interruption" do
    task = Fabricate :active_task
    visit "/tasks/#{task.id}"
    page.should have_content("Running")
    click_link "Interrupt"
    page.should have_content("Pending")
    task.active?.should be_false
  end
  
  scenario "Can't Interrupt Pending Task" do
    task = Fabricate :active_task
    visit "/tasks/#{task.id}"
    task.interrupt!    
    click_link "Interrupt"    
    page.should have_content("This task is already interrupted")
  end

end