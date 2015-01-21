require 'spec_helper'

describe Task do
  it { should belong_to :task_list }
  it { should validate_presence_of(:description).with_message("Sorry, task name can't be empty.") }
  it { should validate_presence_of(:task_list_id).with_message("Sorry, no task list specified.") }
  it { should ensure_length_of(:description).is_at_most(250).with_long_message("Sorry, task can't be longer than 250 characters.") }
  it { should validate_numericality_of(:task_list_id).with_message('Sorry, invalid task list ID.') }
end
