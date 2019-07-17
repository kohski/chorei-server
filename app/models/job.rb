# frozen_string_literal: true

class Job < ApplicationRecord
  after_create :create_schedules
  after_update :update_schedules
  enum frequency: { once: 0, daily: 1, weekly: 2, monthly: 3, yearly: 4 }
  belongs_to :group
  has_many :assigns, dependent: :destroy
  has_many :assign_members, through: :assigns, source: :member
  has_many :steps, dependent: :destroy
  has_many :schedules, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :taggings_tags, through: :taggings, source: :tag
  has_many :stocks, dependent: :destroy
  has_many :stock_users, through: :stocks, source: :user

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1200 }
  validates :image, base_image: true
  validates :base_end_at, is_future_date_job: true
  validates :frequency, inclusion: { in: Job.frequencies.keys }

  scope :assigned_jobs_with_user, lambda { |user|
    user.members.map(&:assign_jobs).flatten
  }

  scope :jobs_with_tags, lambda { |jobs|
    jobs.map do |job|
      tags = job.taggings_tags.map { |tag| tag.slice(:name)[:name] }
      job.attributes.merge(tags: tags)
    end
  }

  def create_schedules
    return if frequency.nil? || repeat_times.nil? || base_start_at.nil? || base_end_at.nil?
    register_times = frequency_before_type_cast.zero? ? 1 : repeat_times + 1
    register_times.times do |register_time|
      frequency_num = frequency_before_type_cast
      start_at = culc_date(base_start_at, frequency_num, register_time)
      end_at = culc_date(base_end_at, frequency_num, register_time)
      schedules.create(start_at: start_at, end_at: end_at)
    end
  end

  def update_schedules
    return if !saved_change_to_repeat_times? && !saved_change_to_frequency? && !saved_change_to_base_start_at? && !saved_change_to_base_end_at?
    return if frequency.nil? || repeat_times.nil? || base_start_at.nil? || base_end_at.nil?
    schedules = Schedule.where(job_id: id)
    schedules.destroy_all if schedules.present?
    register_times = frequency_before_type_cast.zero? ? 1 : repeat_times + 1
    frequency_num = frequency_before_type_cast
    register_times.times do |register_time|
      start_at = culc_date(base_start_at, frequency_num, register_time)
      end_at = culc_date(base_end_at, frequency_num, register_time)
      schedules.create(start_at: start_at, end_at: end_at)
    end
  end

  private

  def culc_date(base_date, frequency_num, register_time)
    base_date + [0, 1.day, 1.week, 1.month, 1.year][frequency_num] * register_time
  end
end
