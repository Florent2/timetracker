require 'spec_helper'

describe Task do
  
  subject { Fabricate :task }
  
  it { should belong_to(:project) }
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
end
