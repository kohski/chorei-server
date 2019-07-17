# frozen_string_literal: true

class Group < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :image, base_image: true
  has_many :members, dependent: :destroy
  has_many :member_users, through: :members, source: :user
  has_many :jobs, dependent: :destroy
  has_many :tags, dependent: :destroy

  scope :group_with_owner_and_members, lambda { |groups|
    groups.map do |group|
      owner = group.members.find { |member| member.is_owner == true } || nil
      owner = User.find(owner.user_id).attributes.slice('name', 'uid', 'image') unless owner.nil?
      group_with_owner = group.attributes.merge(owner: owner)
      group_with_owner.merge(members: group.member_users.map { |user| user.attributes.slice('uid', 'name', 'image') })
    end
  }

  def join_current_user_to_member(current_user)
    member = members.create(user_id: current_user.id)
    member.is_owner = true
  end
end
