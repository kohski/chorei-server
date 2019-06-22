# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag) { build(:tag) }
  context 'name validation' do
    it 'is invalid with over 100 characters name' do
      tag.name = 'a' * 101
      tag.valid?
      expect(tag.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.tag.name'), message: I18n.t('errors.messages.too_long', count: 100)))
    end
  end
  context 'group_id validation' do
    it 'is invalid when group does not exist' do
      tag = create(:tag)
      tag = Tag.new(name: tag.name, group_id: tag.group_id)
      tag.valid?
      expect(tag.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.tag.name'), message: I18n.t('errors.messages.taken')))
    end
  end
end
