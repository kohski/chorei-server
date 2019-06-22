# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    name { 'test tag' }
    group_id { Group.first ? Group.first.id : create(:group).id }
  end
end
