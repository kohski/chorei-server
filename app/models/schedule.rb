# frozen_string_literal: true

class Schedule < ApplicationRecord
  belongs_to :job
  validates :start_at, presence: true
  validates :end_at, is_future_date_schedule: true
end
