# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Schedules', type: :request do
  describe '/schedules' do
    login
    let(:bld_schedule) { build(:schedule) }
    let(:crt_schedule) { create(:schedule) }
    let(:member) { create(:member) }
    context '[POST] /schedules #schedules#create' do
      it 'returns a valid 201 with valid request' do
        bld_schedule
        member
        post(
          api_v1_job_schedules_path(bld_schedule.job.id),
          headers: User.first.create_new_auth_token,
          params: {
            schedule: {
              job_id: bld_schedule.job_id,
              start_at: bld_schedule.start_at,
              end_at: bld_schedule.end_at,
              is_done: bld_schedule.is_done
            }
          }
        )
        res_body = JSON.parse(response.body)
        schedule = Schedule.last
        expect(res_body['status']).to eq(201)
        expect(res_body['message']).to include('Created')
        expect(res_body['data']['id']).to eq(schedule.id)
        expect(res_body['data']['job_id']).to eq(schedule.job_id)
        expect(Time.parse(res_body['data']['start_at'])).to eq(schedule.start_at)
        expect(Time.parse(res_body['data']['end_at'])).to eq(schedule.end_at)
        expect(res_body['data']['is_done']).to eq(schedule.is_done)
      end
      it 'returns an invalid 404 when job does not exist' do
        bld_schedule
        member
        post(
          api_v1_job_schedules_path(bld_schedule.job.id + 1),
          headers: User.first.create_new_auth_token,
          params: {
            schedule: {
              job_id: bld_schedule.job_id,
              start_at: bld_schedule.start_at,
              end_at: bld_schedule.end_at,
              is_done: bld_schedule.is_done
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when current_user is not member' do
        bld_schedule
        post(
          api_v1_job_schedules_path(bld_schedule.job.id),
          headers: User.first.create_new_auth_token,
          params: {
            schedule: {
              job_id: bld_schedule.job_id,
              start_at: bld_schedule.start_at,
              end_at: bld_schedule.end_at,
              is_done: bld_schedule.is_done
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[GET] /schedules #schedules#index' do
      it 'returns a valid 201 with valid request' do
        crt_schedule
        member
        get(
          api_v1_job_schedules_path(crt_schedule.job.id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        schedule = Schedule.last
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data'][0]['id']).to eq(schedule.id)
        expect(res_body['data'][0]['job_id']).to eq(schedule.job_id)
        expect(Time.at(Time.parse(res_body['data'][0]['start_at']).to_i)).to eq(Time.at(schedule.start_at.to_i))
        expect(Time.at(Time.parse(res_body['data'][0]['end_at']).to_i)).to eq(Time.at(schedule.end_at.to_i))
        expect(res_body['data'][0]['is_done']).to eq(schedule.is_done)
      end
      it 'returns an invalid 404 when job does not exist' do
        crt_schedule
        member
        get(
          api_v1_job_schedules_path(crt_schedule.job.id + 1),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when current_user is not member' do
        crt_schedule
        get(
          api_v1_job_schedules_path(crt_schedule.job.id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[GET] /schedules/{schedule_id} #schedules#show' do
      it 'returns a valid 200 with valid request' do
        crt_schedule
        member
        get(
          api_v1_schedule_path(id: crt_schedule.id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        schedule = Schedule.last
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['id']).to eq(schedule.id)
        expect(res_body['data']['job_id']).to eq(schedule.job_id)
        expect(Time.at(Time.parse(res_body['data']['start_at']).to_i)).to eq(Time.at(schedule.start_at.to_i))
        expect(Time.at(Time.parse(res_body['data']['end_at']).to_i)).to eq(Time.at(schedule.end_at.to_i))
        expect(res_body['data']['is_done']).to eq(schedule.is_done)
      end
      it 'returns an invalid 404 when job does not exist' do
        crt_schedule
        member
        get(
          api_v1_schedule_path(id: crt_schedule.id + 1),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when current_user is not member' do
        crt_schedule
        get(
          api_v1_schedule_path(id: crt_schedule.id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[PUT] /schedules/{schedule_id} #schedules#update' do
      it 'returns a valid 200 with valid request' do
        crt_schedule
        member
        update_params = {
          start_at: bld_schedule.start_at + 1000,
          end_at: bld_schedule.end_at + 1000,
          is_done: !bld_schedule.is_done
        }
        put(
          api_v1_schedule_path(id: crt_schedule.id),
          headers: User.first.create_new_auth_token,
          params: {
            schedule: update_params
          }
        )
        res_body = JSON.parse(response.body)
        schedule = Schedule.last
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['id']).to eq(schedule.id)
        expect(res_body['data']['job_id']).to eq(schedule.job_id)
        expect(Time.at(Time.parse(res_body['data']['start_at']).to_i)).to eq(Time.at(update_params[:start_at].to_i))
        expect(Time.at(Time.parse(res_body['data']['end_at']).to_i)).to eq(Time.at(update_params[:end_at].to_i))
        expect(res_body['data']['is_done']).to eq(update_params[:is_done])
      end
      it 'returns an invalid 404 when job does not exist' do
        crt_schedule
        member
        update_params = {
          start_at: bld_schedule.start_at + 1000,
          end_at: bld_schedule.end_at + 1000,
          is_done: !bld_schedule.is_done
        }
        put(
          api_v1_schedule_path(id: (crt_schedule.id + 1)),
          headers: User.first.create_new_auth_token,
          params: {
            schedule: update_params
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when current_user is not member' do
        crt_schedule
        update_params = {
          start_at: bld_schedule.start_at + 1000,
          end_at: bld_schedule.end_at + 1000,
          is_done: !bld_schedule.is_done
        }
        put(
          api_v1_schedule_path(id: crt_schedule.id),
          headers: User.first.create_new_auth_token,
          params: {
            schedule: update_params
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[DELETE] /schedules/{schedule_id} #schedules#destroy' do
      it 'returns a valid 200 with valid request' do
        crt_schedule
        member
        delete(
          api_v1_schedule_path(id: crt_schedule.id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['id']).to eq(crt_schedule.id)
        expect(res_body['data']['job_id']).to eq(crt_schedule.job_id)
        expect(Time.at(Time.parse(res_body['data']['start_at']).to_i)).to eq(Time.at(crt_schedule.start_at.to_i))
        expect(Time.at(Time.parse(res_body['data']['end_at']).to_i)).to eq(Time.at(crt_schedule.end_at.to_i))
        expect(res_body['data']['is_done']).to eq(crt_schedule.is_done)
      end
      it 'returns an invalid 404 when job does not exist' do
        crt_schedule
        member
        delete(
          api_v1_schedule_path(id: crt_schedule.id + 1),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when current_user is not member' do
        crt_schedule
        delete(
          api_v1_schedule_path(id: crt_schedule.id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
  end
end
