# frozen_string_literal: true

class Member < ApplicationRecord
  before_update :reset_owner

  belongs_to :user
  belongs_to :group
  validates :user_id, uniqueness: { scope: :group_id }
  has_many :assigns, dependent: :destroy
  has_many :assign_jobs, through: :assigns, source: :job

  scope :find_owner, lambda { |group|
    group.members.find(&:is_owner)
  }

  def self.in_member?(group, user)
    where(group_id: group.id).pluck(:user_id).index(user.id).present?
  end

  def self.find_by_job_and_user(job, user)
    job.group.members.find { |elm| elm.user_id == user.id }
  end

  def self.last_member?(member)
    member.group.members.count <= 1
  end

  def reset_owner
    return if is_owner == is_owner_was
    before_owner = self.class.find_by(group_id: group_id, is_owner: true)
    before_owner&.update_column('is_owner', false)
    update_column('is_owner', true)
  end
end
