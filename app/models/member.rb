# frozen_string_literal: true

class Member < ApplicationRecord
  belongs_to :user
  belongs_to :group
  validates :user_id, uniqueness: { scope: :group_id }
end
