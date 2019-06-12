# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Assign, type: :model do
  let(:assign) { create(:assign) }
  context 'duplicate validator' do
    it 'is invalid when duplicate register member and job' do
      job = Job.find_by(id: assign.job_id)
      another_assign = job.assigns.create(member_id: assign.member_id)
      another_assign.valid?
      expect(another_assign.errors.full_messages[0]).to include(I18n.t('errors.messages.taken'))
    end
  end
end
