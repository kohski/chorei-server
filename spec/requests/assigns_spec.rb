# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Assigns', type: :request do
  login
  let(:bld_assign) { build(:assign) }
  let(:crt_assign) { create(:assign) }
  let(:crt_another_assign) { create(:assign) }
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
      it 'returns an invalid 403 when current user is not member' do
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
        expect(res_body['status']).to eq(403)
        expect(res_body['message']).to include('Forbidden')
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
      it 'returns an invalid 403 when current_user is Forbidden delete assign' do
        delete(
          api_v1_assigns_path + '/' + crt_assign.id.to_s,
          headers: another_user.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(403)
        expect(res_body['message']).to include('Forbidden')
      end
    end
    context '[GET] /assgins #assgins#index_assign_members' do
      it 'returns a valid 200 with valid request' do
        crt_assign
        get(
          assign_member_api_v1_assigns_path + "?job_id=#{crt_assign.job_id}",
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data'].length).to eq(1)
        expect(res_body['data'][0]['name']).to eq(User.first.name)
        expect(res_body['data'][0]['image']).to eq(User.first.image)
      end
      it 'returns a valid 404 with valid request' do
        dummy_job_id = crt_assign.job_id
        Assign.destroy_all
        Job.destroy_all
        get(
          assign_member_api_v1_assigns_path + "?job_id=#{dummy_job_id}",
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
    end
    context '[POST] /assgins #assgins#create_assign_with_user_id' do
      it 'returns a valid 200 with valid request' do
        bld_assign
        post(
          assign_with_user_id_api_v1_assigns_path,
          headers: User.first.create_new_auth_token,
          params: {
            assign: {
              user_id: bld_assign.member.user.id,
              job_id: bld_assign.job_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['member_id']).to eq(bld_assign.member_id)
        expect(res_body['data']['job_id']).to eq(bld_assign.job_id)
      end
      it 'returns an invalid 404 when user does not exist' do
        bld_assign
        post(
          assign_with_user_id_api_v1_assigns_path,
          headers: User.first.create_new_auth_token,
          params: {
            assign: {
              user_id: (bld_assign.member.user.id + 1),
              job_id: bld_assign.job_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 404 when job does not exist' do
        bld_assign
        post(
          assign_with_user_id_api_v1_assigns_path,
          headers: User.first.create_new_auth_token,
          params: {
            assign: {
              user_id: bld_assign.member.user.id,
              job_id: (bld_assign.job_id + 1)
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 403 when member does not exist' do
        crt_assign
        another_user
        post(
          assign_with_user_id_api_v1_assigns_path,
          headers: User.first.create_new_auth_token,
          params: {
            assign: {
              user_id: another_user.id,
              job_id: crt_assign.job_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(403)
        expect(res_body['message']).to include('Forbidden')
      end
      it 'returns an invalid 400 with duplicate request' do
        crt_assign
        post(
          assign_with_user_id_api_v1_assigns_path,
          headers: User.first.create_new_auth_token,
          params: {
            assign: {
              user_id: crt_assign.member.user.id,
              job_id: crt_assign.job_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(400)
        expect(res_body['message']).to include('Bad Request')
      end
      it 'returns an invalid 403 when user is not job member' do
        bld_assign
        post(
          assign_with_user_id_api_v1_assigns_path,
          headers: another_user.create_new_auth_token,
          params: {
            assign: {
              user_id: bld_assign.member.user.id,
              job_id: bld_assign.job_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(403)
        expect(res_body['message']).to include('Forbidden')
      end
    end

    context '[DELETE] /assgins #assgins#destroy_assign_with_user_id' do
      it 'returns a valid 200 with valid request' do
        crt_assign
        delete(
          assign_with_user_id_api_v1_assigns_path + "?job_id=#{crt_assign.job_id}&user_id=#{crt_assign.member.user_id}",
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['member_id']).to eq(bld_assign.member_id)
        expect(res_body['data']['job_id']).to eq(bld_assign.job_id)
      end
      it 'returns an invalid 404 when job does not exist' do
        crt_assign
        delete(
          assign_with_user_id_api_v1_assigns_path + "?job_id=#{crt_assign.job_id + 1}&user_id=#{crt_assign.member.user_id}",
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 404 when job does not exist' do
        crt_assign
        bld_assign
        delete(
          assign_with_user_id_api_v1_assigns_path + "?job_id=#{crt_assign.job_id}&user_id=#{crt_assign.member.user_id + 1}",
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 403 when current_user is not member of job' do
        crt_assign
        bld_assign
        delete(
          assign_with_user_id_api_v1_assigns_path + "?job_id=#{crt_assign.job_id}&user_id=#{crt_assign.member.user_id}",
          headers: another_user.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(403)
        expect(res_body['message']).to include('Forbidden')
      end
      it 'returns an invalid 403 when target_user is not member of job' do
        crt_assign
        bld_assign
        delete(
          assign_with_user_id_api_v1_assigns_path + "?job_id=#{crt_assign.job_id}&user_id=#{another_user.id}",
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(403)
        expect(res_body['message']).to include('Forbidden')
      end
    end
  end
end
