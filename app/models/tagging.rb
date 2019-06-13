# frozen_string_literal: true

class Tagging < ApplicationRecord
  belongs_to :job
  belongs_to :tag

  validates :job_id, uniqueness: { scope: :tag_id }
end
