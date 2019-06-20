# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Step, type: :model do
  let(:step) { build(:step) }
  let(:step_first) { create(:step, order: 0) }
  let(:step_second) { create(:step, order: 1) }
  let(:step_third) { create(:step, order: 2) }
  let(:step_fource) { create(:step, order: 1) }

  let(:step_order_first) { create(:step) }
  let(:step_order_second) { create(:step) }
  let(:step_order_third) { create(:step) }
  let(:step_order_fource) { create(:step) }
  context 'memo validation' do
    it 'is invalid with name over 400 characters' do
      step.memo = 'a' * 401
      step.valid?
      expect(step.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.step.memo'), message: I18n.t('errors.messages.too_long', count: 400)))
    end
  end
  context 'image validation' do
    it 'is valid with gif image' do
      step.image = 'data:image/gif;base64,' + 'random_characters_base64'
      expect(step).to be_valid
    end
    it 'is valid with png image' do
      step.image = 'data:image/png;base64,' + 'random_characters_base64'
      expect(step).to be_valid
    end
    it 'is valid with jpg image' do
      step.image = 'data:image/jpg;base64,' + 'random_characters_base64'
      expect(step).to be_valid
    end
    it 'is valid with jpeg image' do
      step.image = 'data:image/jpeg;base64,' + 'random_characters_base64'
      expect(step).to be_valid
    end
    it 'is invalid with unformatted request' do
      step.image = 'image_dummy_text'
      step.valid?
      expect(step.errors.full_messages).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.step.image'), message: I18n.t('errors.messages.wrong_mime_type')))
    end
  end
  context 'auto_nubering_blank_order method' do
    it 'is valid with gif image' do
      step = create(:step)
      second_step = step.job.steps.create(order: nil)
      expect(second_step.order).to eq(step.order + 1)
    end
  end
  context 'auto_renumbering_order_after_create method works' do
    it 'is valid with gif image' do
      step_first
      step_second
      step_third
      step_fource
      expected_memo_list = [step_first.memo, step_fource.memo, step_second.memo, step_third.memo]
      steps = Step.order(:order)
      expect(steps.pluck(:memo)).to eq(expected_memo_list)
    end
  end
  context 'auto_renumbering_order after destroy' do
    it 'is valid with gif image' do
      step_order_first
      step_order_second
      step_order_third
      step_order_fource
      step_order_second.destroy

      first = Step.find_by(memo: step_order_first.memo)
      third = Step.find_by(memo: step_order_third.memo)
      fource = Step.find_by(memo: step_order_fource.memo)

      expect(first.order).to eq(0)
      expect(third.order).to eq(1)
      expect(fource.order).to eq(2)
    end
  end
end
