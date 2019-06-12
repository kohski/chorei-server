# frozen_string_literal: true

class Group < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :image, base_image: true
  has_many :members, dependent: :destroy
  has_many :member_users, through: :members, source: :user
  has_many :jobs, dependent: :destroy

  def join_current_user_to_member(current_user)
    members.create(user_id: current_user.id)
  end
end
