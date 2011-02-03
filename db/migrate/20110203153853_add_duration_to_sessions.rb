class AddDurationToSessions < ActiveRecord::Migration
  def self.up
    add_column :sessions, :duration, :float, :default => 0.0
    
    Session.reset_column_information
    
    Session.all.each { |session| session.update_attributes!(:duration => ((session.finish - session.start) / 3600.0).round(2)) unless session.running? }
  end

  def self.down
    remove_column :sessions, :duration
  end
end
