# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Schedule, type: :model do
  let(:crt_schedule) { create(:schedule) }
  let(:bld_schedule) { build(:schedule) }
  context 'start_at validation' do
    it 'is invalid without start_at' do
      schedule = crt_schedule
      schedule.start_at = nil
      schedule.valid?
      expect(schedule.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.schedule.start_at'), message: I18n.t('errors.messages.blank')))
    end
  end
  context 'end_at validation' do
    it 'is invalid when end_at is past to start_at' do
      schedule = crt_schedule
      schedule.end_at = schedule.start_at - 1000
      schedule.valid?
      expect(schedule.errors.full_messages[0]).to include(I18n.t('errors.date_custom_format', attribute_start: I18n.t('activerecord.attributes.schedule.start_at'), message: I18n.t('errors.messages.past')))
    end
    it 'is valid when end_at is equal to start_at' do
      schedule = crt_schedule
      schedule.end_at = schedule.start_at
      schedule.valid?
      expect(schedule).to be_valid
    end
  end
end
