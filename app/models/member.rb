# frozen_string_literal: true

class Member < ApplicationRecord
  belongs_to :user
  belongs_to :group
  validates :user_id, uniqueness: { scope: :group_id }
  has_many :assigns, dependent: :destroy
  has_many :assign_jobs, through: :assigns, source: :job
end
