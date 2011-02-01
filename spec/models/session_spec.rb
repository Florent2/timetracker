require 'spec_helper'

describe Session do
  it { should belong_to(:task) }
#  it { should validate_presence_of(:task) }
  it { should validate_presence_of(:start) }
  
  describe "#finish" do
    it "can be blank" do
      session = Fabricate.build :session, :finish => nil
      session.should be_valid      
    end
    it "is valid if after start date" do
      session = Fabricate.build :session, :start => DateTime.current, :finish => DateTime.current.advance(:hours => 1)
      session.should be_valid
    end
    it "is invalid if before start date" do
      session = Fabricate.build :session, :start => DateTime.current, :finish => DateTime.current.advance(:hours => -1)
      session.should be_invalid
      session.errors[:finish].should be
    end
  end
  
  describe "#duration" do
    it "returns the difference between start and finish times in hours (as float)" do
      Fabricate(:session, :start => DateTime.current.advance(:hours => -1, :minutes => -20), :finish => DateTime.current.advance(:hours => +1)).duration.should == 2.33
    end
    it "calculates from the current time if finish time is nil" do
      Fabricate(:session, :start => DateTime.current.advance(:hours => -1, :minutes => -20), :finish => nil).duration.should == 1.33
    end
  end
  
  describe "#finish!" do
    it "returns the current time and sets finish attribute to current time if it's nil" do
      session = Fabricate :session
      result  = session.finish!
      result.should be_true
      session.finish.should == result
    end
    it "returns false if end is already set" do
      session   = Fabricate :session, :finish => Time.zone.now.advance(:hours => 1)
      end_value = session.finish
      session.finish!.should be_false
      session.finish.should == end_value
    end
  end
  
  it ".on_date(date) returns sessions of the given date" do
    session1 = Fabricate :session, :start => DateTime.current.advance(:days => -1), :finish => DateTime.current.advance(:days => -1, :hours => +2)
    session2 = Fabricate :session, :start => DateTime.current.advance(:days => -1, :hours => +2), :finish => DateTime.current.advance(:days => -1, :hours => +5.5)
    session3 = Fabricate :session, :start => DateTime.current.advance(:hours => 0), :finish => DateTime.current.advance(:hours => +1)
    Session.on_date(Date.yesterday).to_set.should == [session1, session2].to_set
  end
  
end
# == Schema Information
#
# Table name: sessions
#
#  id         :integer         not null, primary key
#  task_id    :integer
#  start      :datetime
#  finish     :datetime
#  created_at :datetime
#  updated_at :datetime
#

