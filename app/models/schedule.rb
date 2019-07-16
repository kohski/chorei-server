# frozen_string_literal: true

class Schedule < ApplicationRecord
  belongs_to :job
  validates :start_at, presence: true
  validates :end_at, is_future_date_schedule: true
  scope :assigned_schedules, lambda { |jobs|
    jobs.map(&:schedules).flatten
  }
  scope :assigned_schedules_with_job, lambda { |assigned_schedules, assigned_jobs|
    assigned_schedules.map { |sch| sch.attributes.merge(job_entity: assigned_jobs.find { |job| job.id == sch.job_id }.attributes) }
  }
end
