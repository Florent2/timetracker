require 'spec_helper'

describe Task do
  
  subject { Fabricate :task }
  
  it { should belong_to(:project) }
  it { should have_many(:sessions)}

  it { should validate_presence_of(:project) }  
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).scoped_to(:project_id) }
  
  describe "#project_name" do
    context "for task creation" do
      context "if project_name is filled" do
        it "creates a project and associates the task to this project" do
          task = Fabricate :task, :project_name => "Fantasy League", :project => nil
          task.project.name.should == "Fantasy League"
        end
        it "if a project with this name already exists, it associate the task to this existing project" do
          project = Fabricate :project, :name => "Fantasy League"
          task = Fabricate :task, :project_name => "Fantasy League", :project => nil
          task.project.name.should == "Fantasy League" 
          Project.count.should == 1
        end
        it "if project is also filled, it uses the project aname" do
          task = Fabricate :task, :project => Fabricate(:project, :name => "Music Make"), :project_name => "Fantasy League"
          task.project.name.should == "Fantasy League"
        end        
      end
      it "if no project_name is filled, it associates the task to the project given in the project attribute" do
        project = Fabricate :project
        task    = Fabricate :task, :project => project, :project_name => ""
        task.project.should == project
      end
    end
  end
  
  describe "#duration_total returns task duration in hours" do
    it "returns 0 if task has no sessions" do
      Fabricate(:task).duration_total.should == 0.0
    end
    it "for a task with an unfinished session it does not include the running session" do
      session = Fabricate :session, :start => DateTime.current.advance(:hours => -1)
      session.task.duration_total.should == 0.0
    end
    it "for a task with several sessions" do
      task = Fabricate :task
      Fabricate :session, :task => task, :start => DateTime.current.advance(:hours => -1), :finish => DateTime.current.advance(:hours => +1) # 2 hours
      Fabricate :session, :task => task, :start => DateTime.current.advance(:hours => +1), :finish => DateTime.current.advance(:hours => +4) # 3 hours
      Fabricate :session, :task => task, :start => DateTime.current.advance(:hours => +4), :finish => DateTime.current.advance(:hours => +6) # 2 hours
      task.duration_total.should == 7.0
    end
  end
  
  describe "#running?" do
    let(:task) { Fabricate :task }
    it "returns true if there is an unfinished session" do
      Fabricate :session, :task => task, :finish => DateTime.current.advance(:hours => 4)
      Fabricate :session, :task => task
      task.running?.should be_true
    end
    it "returns false if there are only finished sessions" do
      Fabricate :session, :task => task, :finish => DateTime.current.advance(:hours => 4)
      Fabricate :session, :task => task, :finish => DateTime.current.advance(:hours => 4)
      task.running?.should be_false
    end
    it "returns false if there is no session" do
      task.running?.should be_false
    end
  end
  
  describe "#interrupt!" do
    let(:task) { Fabricate :task }
    it "returns true and finishes the unfinished session if there is one" do
      Fabricate :session, :task => task      
      task.interrupt!.should be_true
      task.running?.should be_false
    end
    it "returns false it there is no session" do
      task.interrupt!.should be_false
    end
    it "returns false if there are only finished session" do
      Fabricate :session, :task => task, :finish => DateTime.current.advance(:hours => 4)
      Fabricate :session, :task => task, :finish => DateTime.current.advance(:hours => 4)      
      task.interrupt!.should be_false      
    end
  end
  
  describe "#resume!" do
    it "returns false if the task is already running" do
      Fabricate(:running_task).resume!.should be_false
    end
    it "creates a new running session for the task" do
      task = Fabricate :interrupted_task
      task.resume!
      task.running?.should be_true
    end
    it "interrupts any other running task" do
      running_task = Fabricate :running_task
      Fabricate(:interrupted_task).resume!
      running_task.running?.should be_false
    end
    it "sets archived to false if the task was archived" do
      task = Fabricate :archived_task
      task.resume!
      task.archived?.should be_false
    end
  end
  
  describe "#duration_current" do
    it "returns 0.0 if the task is interrupted" do
      Fabricate(:interrupted_task).duration_current.should == 0.0
    end
    it "returns the duration of the running session if the task is running" do
      task = Fabricate(:task)
      running_session = Fabricate :session, :task => task, :start => DateTime.current.advance(:hours => -1)
      task.duration_current.should == 1.0
    end
  end
  
  describe ".running_task" do
    it "returns the running task if it exists" do
      2.times { Fabricate :interrupted_task }
      running_task = Fabricate :running_task
      Task.running_task.should == running_task
    end
    it "returns nil if there is no running task" do
      2.times { Fabricate :interrupted_task }
      Task.running_task.should be_nil
    end
  end
  
  it "new running task interrupts previous running task" do
    running_task = Fabricate :running_task
    new_task = Fabricate :running_task
    running_task.running?.should be_false
    new_task.running?.should be_true
  end
  
  describe "#duration_on_date(date)" do
    it "returns 0.00 if there was no session on this date" do
      task = Fabricate :task
      task.duration_on_date(Date.yesterday).should == 0.00
    end
    it "returns the duration of sessions of this date" do
      task = Fabricate :task
      task.sessions << Fabricate(:session, :task => task, :start => DateTime.current.advance(:days => -1), :finish => DateTime.current.advance(:days => -1, :hours => +2)) # 2 hours   
      task.sessions << Fabricate(:session, :task => task, :start => DateTime.current.advance(:days => -1, :hours => +2), :finish => DateTime.current.advance(:days => -1, :hours => +5.5)) # 3 hours   
      task.sessions << Fabricate(:session, :task => task, :start => DateTime.current, :finish => DateTime.current.advance(:hours => +2.5)) # 2.5 hours   
      task.duration_on_date(Date.yesterday).should == 5.50
      task.duration_on_date(Date.today).should == 2.50      
    end
  end
  
  it ".by_dates_from(tasks, date) returns an hash whose keys are dates and values are array of tasks having sessions on the key date" do
    task1 = Fabricate :task # 10 days ago
    task1.sessions << Fabricate(:session, :task => task1, :start => DateTime.current.advance(:days => -10), :finish => DateTime.current.advance(:days => -10, :hours => +2))

    task2 = Fabricate :task # 4 and 2 days ago
    task2.sessions << Fabricate(:session, :task => task2, :start => DateTime.current.advance(:days => -4), :finish => DateTime.current.advance(:days => -4, :hours => +2))
    task2.sessions << Fabricate(:session, :task => task2, :start => DateTime.current.advance(:days => -2), :finish => DateTime.current.advance(:days => -2, :hours => +2))
    
    task3 = Fabricate :task # today and 2 days ago
    task3.sessions << Fabricate(:session, :task => task3, :start => DateTime.current, :finish => DateTime.current.advance(:hours => +2))
    task3.sessions << Fabricate(:session, :task => task3, :start => DateTime.current.advance(:days => -2), :finish => DateTime.current.advance(:days => -2, :hours => +2))
    
    Task.by_dates_from(Task, Date.today.advance(:days => -5)).should == {
      Date.today.advance(:days => -4) => [task2],
      Date.today.advance(:days => -2) => [task2, task3],
      Date.today  => [task3]
    }
  end
  
  describe "#archive!" do
    it "returns true and set archived to true if task was interrupted" do
      task = Fabricate :interrupted_task
      task.archive!.should be_true
      task.archived?.should be_true
    end
    it "returns true, set archived to true and interrupt last session if task was running" do
      task = Fabricate :running_task
      task.archive!
      task.archived?.should be_true
      task.running?.should be_false
    end
    it "returns false if task was already archived" do
      task = Fabricate :archived_task
      task.archive!.should be_false
    end
  end
end



# == Schema Information
#
# Table name: tasks
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  project_id :integer
#  created_at :datetime
#  updated_at :datetime
#  estimation :float
#  archived   :boolean         default(FALSE)
#

