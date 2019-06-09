# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    owner_id { 1 }
    name { 'MyString' }
    image { 'MyString' }
  end
end
