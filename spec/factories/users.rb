# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'test user' }
    sequence(:email) { |n| "test#{n}@test.com" }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
