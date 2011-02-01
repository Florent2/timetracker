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
  
  describe "#duration returns task duration in hours" do
    it "returns 0 if task has no sessions" do
      Fabricate(:task).duration.should == 0.0
    end
    it "for a task with an unfinished session it calculates from the current time" do
      session = Fabricate :session, :start => DateTime.current.advance(:hours => -1)
      session.task.duration.should == 1.0
    end
    it "for a task with several sessions" do
      task = Fabricate :task
      Fabricate :session, :task => task, :start => DateTime.current.advance(:hours => -1), :finish => DateTime.current.advance(:hours => +1) # 2 hours
      Fabricate :session, :task => task, :start => DateTime.current.advance(:hours => +1), :finish => DateTime.current.advance(:hours => +4) # 3 hours
      Fabricate :session, :task => task, :start => DateTime.current.advance(:hours => +4), :finish => DateTime.current.advance(:hours => +6) # 2 hours
      task.duration.should == 7.0
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
  end
  
  describe "#current_duration" do
    it "returns 0.0 if the task is interrupted" do
      Fabricate(:interrupted_task).current_duration.should == 0.0
    end
    it "returns the duration of the running session if the task is running" do
      task = Fabricate(:task)
      running_session = Fabricate :session, :task => task, :start => DateTime.current.advance(:hours => -1)
      task.current_duration.should == 1.0
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
#

