# frozen_string_literal: true

class Member < ApplicationRecord
  belongs_to :user
  belongs_to :group
  validates :user_id, uniqueness: { scope: :group_id }
  has_many :assigns, dependent: :destroy
  has_many :assign_jobs, through: :assigns, source: :job

  def self.in_member?(group, user)
    where(group_id: group.id).pluck(:user_id).index(user.id).present?
  end

  def self.find_by_job_and_user(job, user)
    job.group.members.find { |elm| elm.user_id == user.id }
  end
end
