# frozen_string_literal: true

class Step < ApplicationRecord
  before_create :auto_nubering_blank_order

  belongs_to :job

  validates :memo, length: { maximum: 400 }
  validates :image, base_image: true

  def auto_nubering_blank_order
    self.order = if job.steps.pluck(:id).blank?
                   0
                 else
                   job.steps.pluck(:id).max + 1
                 end
  end
end
