# frozen_string_literal: true

FactoryBot.define do
  factory :assign do
    member_id { Member.first ? Member.first.id : create(:member).id }
    job_id { Job.first ? Job.first.id : create(:job).id }
  end
end
