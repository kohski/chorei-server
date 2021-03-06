# frozen_string_literal: true

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  enum role: { general: 0, admin: 1 }
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable,
         # :trackable,
         :validatable
  include DeviseTokenAuth::Concerns::User

  validates :name, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1200 }
  validates :image, base_image: true
  validates :role, inclusion: { in: User.roles.keys }

  has_many :members, dependent: :destroy
  has_many :member_groups, through: :members, source: :group
  has_many :stocks, dependent: :destroy
  has_many :stock_jobs, through: :stocks, source: :job

  scope :assigned_users_with_job, lambda { |job|
    job.assign_members.pluck(:user_id).map { |user_id| User.find_by(id: user_id) }
  }
end
