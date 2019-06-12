# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Job, type: :model do
  let(:crt_job) { create(:job) }
  let(:bld_job) { create(:job) }
  context 'title validation' do
    it 'is invalid without title' do
      job = crt_job
      job.title = ''
      job.valid?
      expect(job.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.job.title'), message: I18n.t('errors.messages.blank')))
    end
    it 'is invalid with over 100 characters title' do
      job = crt_job
      job.title = 'a' * 101
      job.valid?
      expect(job.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.job.title'), message: I18n.t('errors.messages.too_long', count: 100)))
    end
  end
  context 'description validation' do
    it 'is valid without description' do
      job = crt_job
      job.description = ''
      expect(job.valid?).to eq(true)
    end
    it 'is invalid with over 1200 characters description' do
      job = crt_job
      job.description = 'a' * 1201
      job.valid?
      expect(job.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.job.description'), message: I18n.t('errors.messages.too_long', count: 1200)))
    end
  end
  context 'image validation' do
    it 'is valid with gif image' do
      crt_job.image = 'data:image/gif;base64,' + 'random_characters_base64'
      expect(crt_job).to be_valid
    end
    it 'is valid with png image' do
      crt_job.image = 'data:image/png;base64,' + 'random_characters_base64'
      expect(crt_job).to be_valid
    end
    it 'is valid with jpg image' do
      crt_job.image = 'data:image/jpg;base64,' + 'random_characters_base64'
      expect(crt_job).to be_valid
    end
    it 'is valid with jpeg image' do
      crt_job.image = 'data:image/jpeg;base64,' + 'random_characters_base64'
      expect(crt_job).to be_valid
    end
    it 'is invalid with unformatted request' do
      crt_job.image = 'image_dummy_text'
      crt_job.valid?
      expect(crt_job.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.job.image'), message: I18n.t('errors.messages.wrong_mime_type')))
    end
  end
end
