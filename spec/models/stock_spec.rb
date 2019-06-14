# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Stock, type: :model do
  let(:crt_stock) { create(:stock) }
  it 'is invalid when duplicate register tag and job' do
    stock = Stock.create(job_id: crt_stock.job_id, user_id: crt_stock.user_id)
    expect(stock.errors.full_messages[0]).to include(I18n.t('errors.messages.taken'))
  end
end
