# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Job, type: :model do
  let(:crt_job) { create(:job) }
  let(:bld_job) { create(:job) }
  let(:daily_job) { create(:job, :daily) }
  let(:weekly_job) { create(:job, :weekly) }
  let(:monthly_job) { create(:job, :monthly) }
  let(:yearly_job) { create(:job, :yearly) }
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
  context 'instance method create #create_schedules' do
    it 'makes schedules depending on daily job' do
      daily_job
      schedules = Schedule.all
      expect(Time.at(schedules[0][:start_at].to_i)).to eq(Time.at(daily_job.base_start_at.to_i))
      expect(Time.at(schedules[0][:end_at].to_i)).to eq(Time.at(daily_job.base_end_at.to_i))
      expect(Time.at(schedules[1][:start_at].to_i)).to eq(Time.at((daily_job.base_start_at + 1.day).to_i))
      expect(Time.at(schedules[1][:end_at].to_i)).to eq(Time.at((daily_job.base_end_at + 1.day).to_i))
    end
    it 'makes schedules depending on weekly job' do
      weekly_job
      schedules = Schedule.all
      expect(Time.at(schedules[0][:start_at].to_i)).to eq(Time.at(weekly_job.base_start_at.to_i))
      expect(Time.at(schedules[0][:end_at].to_i)).to eq(Time.at(weekly_job.base_end_at.to_i))
      expect(Time.at(schedules[1][:start_at].to_i)).to eq(Time.at((weekly_job.base_start_at + 1.week).to_i))
      expect(Time.at(schedules[1][:end_at].to_i)).to eq(Time.at((weekly_job.base_end_at + 1.week).to_i))
    end
    it 'makes schedules depending on monthly job' do
      monthly_job
      schedules = Schedule.all
      expect(Time.at(schedules[0][:start_at].to_i)).to eq(Time.at(monthly_job.base_start_at.to_i))
      expect(Time.at(schedules[0][:end_at].to_i)).to eq(Time.at(monthly_job.base_end_at.to_i))
      expect(Time.at(schedules[1][:start_at].to_i)).to eq(Time.at((monthly_job.base_start_at + 1.month).to_i))
      expect(Time.at(schedules[1][:end_at].to_i)).to eq(Time.at((monthly_job.base_end_at + 1.month).to_i))
    end
    it 'makes schedules depending on yearly job' do
      yearly_job
      schedules = Schedule.all
      expect(Time.at(schedules[0][:start_at].to_i)).to eq(Time.at(yearly_job.base_start_at.to_i))
      expect(Time.at(schedules[0][:end_at].to_i)).to eq(Time.at(yearly_job.base_end_at.to_i))
      expect(Time.at(schedules[1][:start_at].to_i)).to eq(Time.at((yearly_job.base_start_at + 1.year).to_i))
      expect(Time.at(schedules[1][:end_at].to_i)).to eq(Time.at((yearly_job.base_end_at + 1.year).to_i))
    end
  end
  context 'instance method create #update_schedules' do
    it 'update schedules when frequency of job is updated' do
      crt_job
      crt_job.update(frequency: 2)
      update_job = Job.find(crt_job.id)
      schedules = Schedule.all
      expect(schedules[0][:start_at]).to eq(update_job.base_start_at)
      expect(schedules[0][:end_at]).to eq(update_job.base_end_at)
      expect(schedules[1][:start_at]).to eq(update_job.base_start_at + 1.week)
      expect(schedules[1][:end_at]).to eq(update_job.base_end_at + 1.week)
    end
    it 'update schedules when repeat_times of job is updated' do
      daily_job
      daily_job.update(repeat_times: 2)
      update_job = Job.find(daily_job.id)
      schedules = Schedule.all
      expect(schedules[0][:start_at]).to eq(update_job.base_start_at)
      expect(schedules[0][:end_at]).to eq(update_job.base_end_at)
      expect(schedules[1][:start_at]).to eq(update_job.base_start_at + 1.day)
      expect(schedules[1][:end_at]).to eq(update_job.base_end_at + 1.day)
      expect(schedules[2][:start_at]).to eq(update_job.base_start_at + 2.day)
      expect(schedules[2][:end_at]).to eq(update_job.base_end_at + 2.day)
    end
  end
end
