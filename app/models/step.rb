class Step < ApplicationRecord
  belongs_to :job

  validates :memo, length: { maximum: 400 }
  validates :image, base_image: true
end
