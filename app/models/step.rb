# frozen_string_literal: true

class Step < ApplicationRecord
  before_create :auto_nubering_blank_order
  after_create :auto_renumbering_order

  belongs_to :job

  validates :memo, length: { maximum: 400 }
  validates :image, base_image: true

  def auto_nubering_blank_order
    return if order.present?
    self.order = if job.steps.pluck(:order).blank?
                   0
                 else
                   job.steps.pluck(:order).max + 1
                 end
  end

  def auto_renumbering_order
    orders = job.steps.pluck(:order)
    return if orders.length == orders.to_set.to_a.length

    # when order is duplicate, renubering order of steps by updated_at by second criteria
    steps_orderd_by_order_and_updated_by = job.steps.all.sort_by { |elm| [elm[:order], -elm[:updated_at].to_f] }
    steps_orderd_by_order_and_updated_by.each_with_index do |step, index|
      step.order = index
      step.record_timestamps = false
      step.save
      step.record_timestamps = true
    end
  end
end
