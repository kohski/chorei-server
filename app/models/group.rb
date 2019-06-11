# frozen_string_literal: true

class Group < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :image, base_image: true
  belongs_to :owner, class_name: 'User', foreign_key: :owner_id
  has_many :members, dependent: :destroy
  has_many :member_users, through: :members, source: :user
end
