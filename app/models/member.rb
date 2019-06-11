# frozen_string_literal: true

class Member < ApplicationRecord
  belongs_to :user
  belongs_to :group

  def self.duplicate?(member)
    user_id = member[:user_id]
    group_id = member[:group_id]
    members = all.map do |elm|
      { user_id: elm.user_id, group_id: elm.group_id }
    end
    members.map { |elm| elm[:user_id] == user_id && elm[:group_id] == group_id }.any?
  end
end
