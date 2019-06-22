# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  belongs_to :group

  validates :name, presence: true, length: { maximum: 100 }
  validates :name, uniqueness: { scope: :group }
end
