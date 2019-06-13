# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Assigns', type: :request do
  login
  let(:bld_assign) { build(:assign) }
  let(:crt_assign) { create(:assign) }
  let(:another_user) { create(:user) }
  let(:member) { User.first.members.create(group_id: Group.first.id) }
  describe '/assigns' do
    context '[POST] /assgins #assgins#create' do
      it 'returns a valid 201 with valid request' do
        bld_assign
        post(
          api_v1_assigns_path,
          headers: User.first.create_new_auth_token,
          params: {
            assign: {
              "job_id": bld_assign.job_id,
              "member_id": bld_assign.member_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        assign = Assign.last
        expect(res_body['status']).to eq(201)
        expect(res_body['message']).to include('Created')
        expect(res_body['data']['id']).to eq(assign.id)
        expect(res_body['data']['member_id']).to eq(assign.member_id)
        expect(res_body['data']['job_id']).to eq(assign.job_id)
      end
      it 'returns an invalid 400 with duplicate conbination job_id and member_id' do
        crt_assign
        member
        post(
          api_v1_assigns_path,
          headers: User.first.create_new_auth_token,
          params: {
            assign: {
              "job_id": crt_assign.job_id,
              "member_id": crt_assign.member_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(400)
        expect(res_body['message']).to include('Bad Request')
      end
      it 'returns an invalid 404 when member does not exist' do
        bld_assign
        member
        post(
          api_v1_assigns_path,
          headers: User.first.create_new_auth_token,
          params: {
            assign: {
              "job_id": bld_assign.job_id,
              "member_id": (bld_assign.member_id + 1)
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 404 when job does not exist' do
        bld_assign
        member
        post(
          api_v1_assigns_path,
          headers: User.first.create_new_auth_token,
          params: {
            assign: {
              "job_id": (bld_assign.job_id + 1),
              "member_id": bld_assign.member_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when job or member are not member of current_user joining group' do
        post(
          api_v1_assigns_path,
          headers: another_user.create_new_auth_token,
          params: {
            assign: {
              "job_id": bld_assign.job_id,
              "member_id": bld_assign.member_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[GET] /assgins #assgins#index' do
      it 'returns a valid 200 with valid request' do
        crt_assign
        count = Assign.count
        get(
          api_v1_assigns_path,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data'].length).to eq(count)
        expect(res_body['data'][0]['id']).to eq(crt_assign.job.id)
        expect(res_body['data'][0]['id']).to eq(crt_assign.job.id)
        expect(res_body['data'][0]['id']).to eq(crt_assign.job.id)
        expect(res_body['data'][0]['title']).to eq(crt_assign.job.title)
        expect(res_body['data'][0]['description']).to eq(crt_assign.job.description)
        expect(res_body['data'][0]['image']).to eq(crt_assign.job.image)
        expect(res_body['data'][0]['is_public']).to eq(crt_assign.job.is_public)
      end
      it 'returns an invalid 404 when member does not exist' do
        get(
          api_v1_assigns_path,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
    end
    context '[DELETE] /assgins #assgins#destroy' do
      it 'returns a valid 200 with valid request' do
        delete(
          api_v1_assigns_path + '/' + crt_assign.id.to_s,
          headers: User.first.create_new_auth_token,
          params: {
            assign: {
              "job_id": crt_assign.job_id,
              "member_id": crt_assign.member_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['id']).to eq(crt_assign.id)
        expect(res_body['data']['member_id']).to eq(crt_assign.member_id)
        expect(res_body['data']['job_id']).to eq(crt_assign.job_id)
      end
      it 'returns an invalid 404 when assign does not exist' do
        dummy_assign_id = crt_assign.id
        Assign.destroy_all
        delete(
          api_v1_assigns_path + '/' + dummy_assign_id.to_s,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when current_user is not acceptable delete assign' do
        delete(
          api_v1_assigns_path + '/' + crt_assign.id.to_s,
          headers: another_user.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
  end
end
