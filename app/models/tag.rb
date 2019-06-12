# frozen_string_literal: true

class Tag < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
end
