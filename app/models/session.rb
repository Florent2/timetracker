class Session < ActiveRecord::Base
  belongs_to :task, :touch => true
  
#  validates_presence_of :task # must be commented because when created during a task creation task_id is not set
  validates_presence_of :start
  
  validates_datetime :end, :after => :start, :allow_blank => true
  
  scope :active, where(:end => nil)
  
  def active?
    self.end.nil?
  end
  
  def duration
    end_datetime = self.end || Time.zone.now
    ((end_datetime - start) / 3600.0).round 2
  end
  
  def finish!
    result = false
    if active?
      result = Time.zone.now
      update_attributes! :end => result
    end
    result    
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

