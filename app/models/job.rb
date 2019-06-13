# frozen_string_literal: true

class Job < ApplicationRecord
  belongs_to :group
  has_many :assigns, dependent: :destroy
  has_many :assign_members, through: :assigns, source: :member
  has_many :steps, dependent: :destroy

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1200 }
  validates :image, base_image: true
end
