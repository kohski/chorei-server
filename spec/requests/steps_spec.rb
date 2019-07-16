# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Steps', type: :request do
  login
  let(:bld_step) { build(:step) }
  let(:crt_step) { create(:step) }
  let(:member) { create(:member) }
  let(:another_user) { create(:user) }
  describe '/steps' do
    context '[POST] /steps #steps#create' do
      it 'returns a valid 201 with valid request' do
        bld_step
        member
        post(
          api_v1_job_steps_path(bld_step.job.id),
          headers: User.first.create_new_auth_token,
          params: {
            step: {
              memo: bld_step.memo,
              image: bld_step.image,
              order: bld_step.order
            }
          }
        )
        res_body = JSON.parse(response.body)
        step = Step.last
        expect(res_body['status']).to eq(201)
        expect(res_body['message']).to include('Created')
        expect(res_body['data']['id']).to eq(step.id)
        expect(res_body['data']['memo']).to eq(step.memo)
        expect(res_body['data']['image']).to eq(step.image)
        expect(res_body['data']['order']).to eq(step.order)
      end
      it 'returns an invalid 404 when job does not exist' do
        bld_step
        member
        post(
          api_v1_job_steps_path((bld_step.job.id + 1)),
          headers: User.first.create_new_auth_token,
          params: {
            step: {
              memo: bld_step.memo,
              image: bld_step.image,
              order: bld_step.order
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 403 when current user is not member of job group' do
        bld_step
        another_user
        post(
          api_v1_job_steps_path(bld_step.job.id),
          headers: another_user.create_new_auth_token,
          params: {
            step: {
              memo: bld_step.memo,
              image: bld_step.image,
              order: bld_step.order
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(403)
        expect(res_body['message']).to include('Forbidden')
      end
      it 'returns an invalid 400 when memo is over 400 chars' do
        bld_step
        member
        bld_step.memo = "a" * 401
        post(
          api_v1_job_steps_path(bld_step.job.id),
          headers: User.first.create_new_auth_token,
          params: {
            step: {
              memo: bld_step.memo,
              image: bld_step.image,
              order: bld_step.order
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(400)
        expect(res_body['message']).to include('Bad Request')
      end
    end
    context '[GET] /steps #steps#index' do
      it 'returns a valid 200 with valid request' do
        crt_step
        member
        get(
          api_v1_job_steps_path(crt_step.job.id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        step = Step.last
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data'].length).to eq(crt_step.job.steps.length)
        expect(res_body['data'][0]['id']).to eq(step.id)
        expect(res_body['data'][0]['memo']).to eq(step.memo)
        expect(res_body['data'][0]['image']).to eq(step.image)
        expect(res_body['data'][0]['order']).to eq(step.order)
      end
      it 'returns an invalid 404 when job does not exist' do
        dummy_job_id = crt_step.job.id
        member
        crt_step.job.destroy
        get(
          api_v1_job_steps_path(dummy_job_id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 404 when steps do not exist' do
        job_id = crt_step.job.id
        Step.destroy_all
        member
        get(
          api_v1_job_steps_path(job_id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 403 when current user is not member of job group' do
        crt_step
        another_user
        get(
          api_v1_job_steps_path(crt_step.job.id),
          headers: another_user.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(403)
        expect(res_body['message']).to include('Forbidden')
      end
    end
    context '[GET] /steps/{step_id} #steps#show' do
      it 'returns a valid 200 with valid request' do
        crt_step
        member
        get(
          api_v1_step_path(crt_step),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        step = Step.last
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['id']).to eq(step.id)
        expect(res_body['data']['memo']).to eq(step.memo)
        expect(res_body['data']['image']).to eq(step.image)
        expect(res_body['data']['order']).to eq(step.order)
      end
      it 'returns an invalid 404 when step does not exist' do
        dummy_step_id = crt_step.id
        crt_step.destroy
        member
        get(
          api_v1_step_path(id: dummy_step_id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 403 when current user is not member of job group' do
        crt_step
        get(
          api_v1_step_path(crt_step),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(403)
        expect(res_body['message']).to include('Forbidden')
      end
    end
    context '[PUT] /steps #steps#update' do
      it 'returns a valid 200 with valid request' do
        crt_step
        member
        update_info = {
          memo: crt_step.memo + '_updated',
          image: crt_step.image + '_updated',
          order: crt_step.order + 1
        }
        put(
          api_v1_step_path(crt_step),
          headers: User.first.create_new_auth_token,
          params: {
            step: update_info
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['id']).to eq(crt_step.id)
        expect(res_body['data']['memo']).to eq(update_info[:memo])
        expect(res_body['data']['image']).to eq(update_info[:image])
        expect(res_body['data']['order']).to eq(update_info[:order])
      end
      it 'returns an invalid 404 when step does not exist' do
        crt_step
        member
        update_info = {
          memo: crt_step.memo + '_updated',
          image: crt_step.image + '_updated',
          order: crt_step.order + 1
        }
        put(
          api_v1_step_path(id: crt_step.id + 1),
          headers: User.first.create_new_auth_token,
          params: {
            step: update_info
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 403 when current user is not member of job group' do
        crt_step
        update_info = {
          memo: crt_step.memo + '_updated',
          image: crt_step.image + '_updated',
          order: crt_step.order + 1
        }
        put(
          api_v1_step_path(crt_step),
          headers: User.first.create_new_auth_token,
          params: {
            step: update_info
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(403)
        expect(res_body['message']).to include('Forbidden')
      end
    end
    context '[DELETE] /steps #steps#destroy' do
      it 'returns a valid 200 with valid request' do
        crt_step
        member
        delete(
          api_v1_step_path(crt_step),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['id']).to eq(crt_step.id)
        expect(res_body['data']['memo']).to eq(crt_step.memo)
        expect(res_body['data']['image']).to eq(crt_step.image)
        expect(res_body['data']['order']).to eq(crt_step.order)
      end
      it 'returns an invalid 404 when step does not exist' do
        crt_step
        member
        delete(
          api_v1_step_path(id: crt_step.id + 1),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 403 when current user is not member of job group' do
        crt_step
        delete(
          api_v1_step_path(crt_step),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(403)
        expect(res_body['message']).to include('Forbidden')
      end
    end
  end
end
