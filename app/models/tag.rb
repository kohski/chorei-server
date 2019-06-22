# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  belongs_to :group

  validates :name, presence: true, length: { maximum: 100 }
  validates :group_id, uniqueness: { scope: :group }
end
