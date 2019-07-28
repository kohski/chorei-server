# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Schedules', type: :request do
  describe '/schedules' do
    login
    let(:bld_schedule) { build(:schedule) }
    let(:crt_schedule) { create(:schedule) }
    let(:member) { create(:member) }
    let(:assign) { create(:assign) }
    context '[GET] /assigned_schedules #schedules#index_assigned_schedules' do
      it 'returns a valid 200 with valid request' do
        crt_schedule
        member
        assign
        get(
          api_v1_assigned_schedules_path,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
      end
      it 'returns an invalid 404 when schedules does not exist' do
        crt_schedule
        member
        get(
          api_v1_assigned_schedules_path,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
    end
  end
end
