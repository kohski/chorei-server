# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  context 'name validation' do
    it 'is invalid without name' do
      user.name = nil
      user.valid?
      expect(user.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.user.name'), message: I18n.t('errors.messages.blank')))
    end
    it 'is invalid with name over 100 characters' do
      user.name = 'a' * 101
      user.valid?
      expect(user.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.user.name'), message: I18n.t('errors.messages.too_long', count: 100)))
    end
  end
  context 'description validation' do
    it 'is valid without description' do
      user.description = nil
      user.valid?
      expect(user.errors.full_messages).to be_blank
    end
    it 'is invalid with name over 1200 characters' do
      user.description = 'a' * 1201
      user.valid?
      expect(user.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.user.description'), message: I18n.t('errors.messages.too_long', count: 1200)))
    end
  end
  context 'image validation' do
    it 'is valid with gif image' do
      user.image = 'data:image/gif;base64,' + 'random_characters_base64'
      expect(user).to be_valid
    end
    it 'is valid with png image' do
      user.image = 'data:image/png;base64,' + 'random_characters_base64'
      expect(user).to be_valid
    end
    it 'is valid with jpg image' do
      user.image = 'data:image/jpg;base64,' + 'random_characters_base64'
      expect(user).to be_valid
    end
    it 'is valid with jpeg image' do
      user.image = 'data:image/jpeg;base64,' + 'random_characters_base64'
      expect(user).to be_valid
    end
    it 'is invalid with unformatted request' do
      user.image = 'image_dummy_text'
      user.valid?
      expect(user.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.user.image'), message: I18n.t('errors.messages.wrong_mime_type')))
    end
  end
end
