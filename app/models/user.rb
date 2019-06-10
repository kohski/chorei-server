# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         # :trackable,
         :validatable
  include DeviseTokenAuth::Concerns::User

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1200 }
  validates :image, base_image: true
end
