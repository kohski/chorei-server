# frozen_string_literal: true

class Member < ApplicationRecord
  belongs_to :user
  belongs_to :group

  def self.duplicate_check(member_params)
    all.find do |elm|
      elm[:user_id] == member_params[:user_id].to_i && elm[:group_id] == member_params[:group_id].to_i
    end
  end
end
