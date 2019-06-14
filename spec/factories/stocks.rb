# frozen_string_literal: true

FactoryBot.define do
  factory :stock do
    job_id { Job.first ? Job.first.id : create(:job).id }
    user_id { User.first ? User.first.id : create(:user).id }
  end
end
