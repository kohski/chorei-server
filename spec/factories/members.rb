# frozen_string_literal: true

FactoryBot.define do
  factory :member do
    user_id { create(:user).id }
    group_id { create(:group).id }
  end
end
