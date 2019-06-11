# frozen_string_literal: true

class Member < ApplicationRecord
  belongs_to :user
  belongs_to :group
end
