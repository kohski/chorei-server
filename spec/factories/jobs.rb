# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    group_id { Group.first ? Group.first.id : create(:group).id }
    sequence(:title) { |n| "test job#{n} title" }
    sequence(:description) { |n| "test job#{n} description" }
    image { 'data:image/png;base64,content_text' }
    frequency { 0 }
    repeat_times { 1 }
    base_start_at { Time.now }
    base_end_at { Time.now }
    is_public { false }
    trait :public do
      is_public { true }
    end
  end
end
