# frozen_string_literal: true

class Job < ApplicationRecord
  belongs_to :group

  validates :title, presence: true, length:{ maximum: 100 }
  validates :description, length: { maximum: 1200 }
  validates :image, base_image: true
end
