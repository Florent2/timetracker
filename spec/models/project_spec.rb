require 'spec_helper'

describe Project do
  subject { Fabricate :project }
  it { should have_many(:tasks) }
  it { should validate_uniqueness_of(:name) }
  it { should validate_presence_of(:name) }
end

# == Schema Information
#
# Table name: projects
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

