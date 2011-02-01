require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Interrupt And Resume Task", %q{
  In order to switch between different tasks and take deserved breaks
  As a developer
  I want to interrupt and resume tasks
} do

  scenario "Task Interruption" do
    task = Fabricate :running_task
    visit "/tasks/#{task.id}"
    page.should have_content("Running")
    click_link "Interrupt"
    page.should have_content("Pending")
    task.running?.should be_false
  end
  
  scenario "Can't Interrupt Pending Task" do
    task = Fabricate :running_task
    visit "/tasks/#{task.id}"
    task.interrupt!    
    click_link "Interrupt"    
    page.should have_content("This task is already interrupted")
  end
  
  scenario "Task Resuming" do
    task = Fabricate :interrupted_task
    visit "/tasks/#{task.id}"
    click_link "Resume"
    page.should have_content("Running")
    task.running?.should be_true
  end
  
  scenario "Task Resuming Interrupts Current Running Task" do
    running_task = Fabricate :running_task
    task = Fabricate :interrupted_task
    visit "/tasks/#{task.id}"
    click_link "Resume"
    page.should have_content("Running")
    task.running?.should be_true
    running_task.running?.should be_false
  end

end