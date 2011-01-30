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

