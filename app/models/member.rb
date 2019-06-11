# frozen_string_literal: true

class Member < ApplicationRecord
  belongs_to :user
  belongs_to :group

  def self.duplicate_check(member_params)
    all.find do |elm|
      elm[:user_id] == member_params[:user_id].to_i && elm[:group_id] == member_params[:group_id].to_i
    end
  end

  def self.auto_create_owner_as_member(group)
    user_id = group.owner_id
    group_id = group.id
    self.create(user_id: user_id, group_id: group_id)
  end
end
