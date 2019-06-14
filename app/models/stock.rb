# frozen_string_literal: true

class Stock < ApplicationRecord
  belongs_to :job
  belongs_to :user

  validates :job_id, uniqueness: { scope: :user_id }
end
