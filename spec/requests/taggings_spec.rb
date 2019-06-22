# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Taggings', type: :request do
  describe ' /Taggings' do
    login
    let(:bld_tagging) { build(:tagging) }
    let(:crt_tagging) { create(:tagging) }
    let(:member) { create(:member) }
    context '[POST] /taggings #tags#create' do
      it 'returns a valid 201 with valid request' do
        bld_tagging
        member
        post(
          api_v1_taggings_path,
          headers: User.first.create_new_auth_token,
          params: {
            tagging: {
              job_id: bld_tagging.job_id,
              tag_id: bld_tagging.tag_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        tagging = Tagging.last
        expect(res_body['status']).to eq(201)
        expect(res_body['message']).to include('Created')
        expect(res_body['data']['job_id']).to eq(tagging.job_id)
        expect(res_body['data']['tag_id']).to eq(tagging.tag_id)
      end
      it 'returns a valid 400 when both job and tag have already exist' do
        crt_tagging
        member
        post(
          api_v1_taggings_path,
          headers: User.first.create_new_auth_token,
          params: {
            tagging: {
              job_id: crt_tagging.job_id,
              tag_id: crt_tagging.tag_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(400)
        expect(res_body['message']).to include('Bad Request')
      end
      it 'returns a valid 404 with job does not exist' do
        crt_tagging
        member
        post(
          api_v1_taggings_path,
          headers: User.first.create_new_auth_token,
          params: {
            tagging: {
              job_id: (crt_tagging.job_id + 1),
              tag_id: crt_tagging.tag_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns a valid 404 with tag does not exist' do
        crt_tagging
        member
        post(
          api_v1_taggings_path,
          headers: User.first.create_new_auth_token,
          params: {
            tagging: {
              job_id: crt_tagging.job_id,
              tag_id: (crt_tagging.tag_id + 1)
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns a valid 406 with current_user is not member of job' do
        crt_tagging
        post(
          api_v1_taggings_path,
          headers: User.first.create_new_auth_token,
          params: {
            tagging: {
              job_id: crt_tagging.job_id,
              tag_id: crt_tagging.tag_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[DELETE] /taggings/{tagging_id} #tags#destroy' do
      it 'returns a valid 200 with valid request' do
        crt_tagging
        member
        delete(
          api_v1_taggings_path + '/' + crt_tagging.id.to_s,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['job_id']).to eq(crt_tagging.job_id)
        expect(res_body['data']['tag_id']).to eq(crt_tagging.tag_id)
      end
      it 'returns a valid 404 with tagging does not exist' do
        crt_tagging
        member
        delete(
          api_v1_taggings_path + '/' + (crt_tagging.id + 1).to_s,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns a valid 406 with current_user is not member of job' do
        crt_tagging
        delete(
          api_v1_taggings_path + '/' + crt_tagging.id.to_s,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[GET] /taggings/index_with_job_id?job_id{job_id} #tags#index_with_job_id' do
      it 'returns a valid 200 with valid request' do
        crt_tagging
        member
        get(
          taggings_with_job_id_api_v1_taggings_path + "?job_id=#{crt_tagging.job_id}",
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data'][0]['job_id']).to eq(crt_tagging.job_id)
        expect(res_body['data'][0]['tag_id']).to eq(crt_tagging.tag_id)
      end
      it 'returns an invalid 404 when tagging does not exist' do
        crt_tagging
        member
        get(
          taggings_with_job_id_api_v1_taggings_path + "?job_id=#{crt_tagging.job_id + 1}",
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
    end
  end
end
