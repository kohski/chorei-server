# frozen_string_literal: true

class Group < ApplicationRecord
  after_create :join_owner_to_member

  validates :name, presence: true, length: { maximum: 100 }
  validates :image, base_image: true
  has_many :members, dependent: :destroy
  has_many :member_users, through: :members, source: :user
  has_many :jobs, dependent: :destroy

  # def join_owner_to_member
  #   Member.create(user_id: owner_id, group_id: id)
  # end
end
