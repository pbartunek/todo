FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "user#{n}@example.com" }
    password "secretpassword"
  end

  factory :task_list, aliases: [:list] do
    user
    name "My First List"
  end

  factory :task do
    task_list
    sequence(:description) {|n| "Task #{n}" }
  end
end
