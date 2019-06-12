# frozen_string_literal: true

FactoryBot.define do
  factory :job do
    group_id { 1 }
    title { 'MyString' }
    description { 'MyText' }
    image { 'MyText' }
    is_public { false }
  end
end
