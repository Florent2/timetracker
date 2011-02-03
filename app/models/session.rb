class Session < ActiveRecord::Base
  belongs_to :task, :touch => true
  
#  validates_presence_of :task # must be commented because when created during a task creation task_id is not set
  validates_presence_of :start
  
  validates_datetime :finish, :after => :start, :allow_blank => true

  before_save :set_duration
  
  scope :running, where(:finish => nil)

  def current_duration
    return 0.0 if !running?
    ((Time.zone.now - start) / 3600.0).round 2
  end
  
  def finish!
    result = false
    if running?
      result = Time.zone.now
      update_attributes! :finish => result
    end
    result    
  end

  def self.from_date(date)
    where :start => date.beginning_of_day..Date.today.end_of_day
  end

    # we only compare the start datetime as we consider that a task does not pass midnight (I'm a day worker!)
  def self.on_date(date)
    where :start => date.beginning_of_day..date.end_of_day
  end
  
  def running?
    finish.nil?
  end  
  
  private
  
  def set_duration
    self.duration =  ((finish - start) / 3600.0).round(2) if finish? && finish_changed?
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
#  duration   :float           default(0.0)
#

