# frozen_string_literal: true

FactoryBot.define do
  factory :member do
    user_id { User.first ? User.first.id : create(:user).id }
    group_id { Group.first ? Group.first.id : create(:group).id }
    is_owner { true }
  end
end
