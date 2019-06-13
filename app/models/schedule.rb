# frozen_string_literal: true

class Schedule < ApplicationRecord
  enum frequency: { once: 0, daily: 1, weekly: 2, weekday: 3, weekend: 4, monthly_same_day_of_the_week: 5, yearly: 6 }
  belongs_to :job
  validates :start_at, presence: true
  validates :end_at, is_future_date: true
end
