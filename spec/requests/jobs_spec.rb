require 'rails_helper'

RSpec.describe "Jobs", type: :request do
  describe "GET /jobs" do
    login
    let(:bld_job) { build(:job) }
    let(:crt_job) { create(:job) }
    context '[POST] /members #members#create' do
      it 'returns a valid 201 with valid request' do
      end
    end
  end
end
