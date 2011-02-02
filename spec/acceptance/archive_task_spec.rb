require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Archive Task", %q{
  In order to see only active tasks
  As a developer
  I want to archive old tasks so that they don't clutter the interface
} do

  scenario "Running Task Archiving" do
    task = Fabricate :running_task
    visit "/tasks/#{task.id}"
    click_link "archive"
    page.should have_content("archived")
    task.reload.archived?.should be_true
  end

  scenario "Interrupted Task Archiving" do
    task = Fabricate :interrupted_task
    visit "/tasks/#{task.id}"
    click_link "archive"
    page.should have_content("archived")
    task.reload.archived?.should be_true
  end
  
  scenario "Alreday Archived Task Can Not Be Archived" do
    task = Fabricate :running_task
    visit "/tasks/#{task.id}"
    task.archive!
    click_link "archive"
    page.should have_content("is already archived")
  end
end