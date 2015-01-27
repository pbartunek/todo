require 'spec_helper'

describe TaskList do
  it { should have_many :tasks }
  it { should belong_to :user }
  it { should validate_presence_of :name }
  it { should validate_presence_of :user }
end
