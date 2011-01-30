require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Show Task", %q{
  In order to better estimate
  As a developer
  I want to see how much time has ran a task
} do

  scenario "Displays Task Duration" do
    task = Fabricate.build :task
    task.sessions.build :start => DateTime.current.advance(:hours => -1, :minutes => -20)
    task.save!
    visit "/tasks/#{task.id}"
    page.should have_content "1.33"
  end

end