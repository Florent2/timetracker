require 'spec_helper'

describe Session do
  it { should belong_to(:task) }
#  it { should validate_presence_of(:task) }
  it { should validate_presence_of(:start) }
  
  describe "#end" do
    it "can be blank" do
      session = Fabricate.build :session, :end => nil
      session.should be_valid      
    end
    it "is valid if after start date" do
      session = Fabricate.build :session, :start => DateTime.current, :end => DateTime.current.advance(:hours => 1)
      session.should be_valid
    end
    it "is invalid if before start date" do
      session = Fabricate.build :session, :start => DateTime.current, :end => DateTime.current.advance(:hours => -1)
      session.should be_invalid
      session.errors[:end].should be
    end
  end
  
  describe "#duration" do
    it "returns the difference between start and end times in hours (as float)" do
      Fabricate(:session, :start => DateTime.current.advance(:hours => -1, :minutes => -20), :end => DateTime.current.advance(:hours => +1)).duration.should == 2.33
    end
    it "calculates from the current time if end time is nil" do
      Fabricate(:session, :start => DateTime.current.advance(:hours => -1, :minutes => -20), :end => nil).duration.should == 1.33
    end
  end
  
  describe "#finish!" do
    it "returns the current time and sets end attribute to current time if it's nil" do
      session = Fabricate :session
      result  = session.finish!
      result.should be_true
      session.end.should == result
    end
    it "returns false if end is already set" do
      session   = Fabricate :session, :end => Time.zone.now.advance(:hours => 1)
      end_value = session.end
      session.finish!.should be_false
      session.end.should == end_value
    end
  end
end

# == Schema Information
#
# Table name: sessions
#
#  id         :integer         not null, primary key
#  task_id    :integer
#  start      :datetime
#  end        :datetime
#  created_at :datetime
#  updated_at :datetime
#

