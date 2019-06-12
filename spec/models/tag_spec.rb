# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  context 'name validation' do
    let(:tag) { build(:tag) }
    it 'is invalid with over 100 characters name' do
      tag.name = 'a' * 101
      tag.valid?
      expect(tag.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.tag.name'), message: I18n.t('errors.messages.too_long', count: 100)))
    end
  end
end
