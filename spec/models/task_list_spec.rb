require 'spec_helper'

describe TaskList do
  it { should have_many :tasks }
  it { should belong_to :user }
  it { should validate_presence_of :name }
  it { should validate_presence_of :user }

  context "task counters and limits" do
    let!(:user) { create(:user) }
    let!(:list) { create(:list) }

    before do
      25.times do |i|
        t = Task.create(description: "Task #{i}", task_list: list, done: false)
        t.save
      end
    end

#    it "should limit task number to 25" do
#      expect { Task.create!(description: "Another task", task_list: list) }.to raise_error(ActiveRecord::RecordInvalid)
#    end
  end
end
