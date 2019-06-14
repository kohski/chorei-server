# frozen_string_literal: true

FactoryBot.define do
  factory :tagging do
    job_id { Job.first ? Job.first.id : create(:job).id }
    tag_id { Tag.first ? Tag.first.id : create(:tag).id }
  end
end
