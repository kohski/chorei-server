# frozen_string_literal: true

class Assign < ApplicationRecord
  belongs_to :job
  belongs_to :member
  validates :job_id, uniqueness: { scope: :member_id }
end
