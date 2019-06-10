# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Group, type: :model do
  let(:group) { create(:group) }
  context 'name validation' do
    it 'is invalid without name' do
      group.name = nil
      group.valid?
      expect(group.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.group.name'), message: I18n.t('errors.messages.blank')))
    end
    it 'is invalid with name over 100 characters' do
      group.name = 'a' * 101
      group.valid?
      expect(group.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.group.name'), message: I18n.t('errors.messages.too_long', count: 100)))
    end
  end
  context 'image validation' do
    it 'is valid with gif image' do
      group.image = 'data:image/gif;base64,' + 'random_characters_base64'
      expect(group).to be_valid
    end
    it 'is valid with png image' do
      group.image = 'data:image/png;base64,' + 'random_characters_base64'
      expect(group).to be_valid
    end
    it 'is valid with jpg image' do
      group.image = 'data:image/jpg;base64,' + 'random_characters_base64'
      expect(group).to be_valid
    end
    it 'is valid with jpeg image' do
      group.image = 'data:image/jpeg;base64,' + 'random_characters_base64'
      expect(group).to be_valid
    end
    it 'is invalid with unformatted request' do
      group.image = 'image_dummy_text'
      group.valid?
      expect(group.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.group.image'), message: I18n.t('errors.messages.wrong_mime_type')))
    end
  end
end
