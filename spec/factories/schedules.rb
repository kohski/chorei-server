# frozen_string_literal: true

FactoryBot.define do
  factory :schedule do
    job_id { Job.first ? Job.first.id : create(:job).id }
    start_at { Time.now }
    end_at { Time.now }
    is_done { false }
  end
end
