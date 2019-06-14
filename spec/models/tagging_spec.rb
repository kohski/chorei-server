# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tagging, type: :model do
  let(:tagging) { create(:tagging) }
  it 'is invalid when duplicate register tag and job' do
    another_tagging = Tagging.create(job_id: tagging.job_id, tag_id: tagging.tag_id)
    expect(another_tagging.errors.full_messages[0]).to include(I18n.t('errors.messages.taken'))
  end
end
