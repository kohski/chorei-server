# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tags', type: :request do
  describe '/tags' do
    login
    let(:bld_tag) { build(:tag) }
    let(:crt_tag) { create(:tag) }
    let(:crt_job) { create(:job) }
    context '[POST] /tags #tags#create' do
      it 'returns a valid 201 with valid request' do
        bld_tag
        post(
          api_v1_tags_path,
          headers: User.first.create_new_auth_token,
          params: {
            tag: {
              name: bld_tag.name,
              group_id: bld_tag.group_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        tag = Tag.last
        expect(res_body['status']).to eq(201)
        expect(res_body['message']).to include('Created')
        expect(res_body['data']['id']).to eq(tag.id)
        expect(res_body['data']['name']).to eq(bld_tag.name)
      end
      it 'returns a valid 400 without name' do
        post(
          api_v1_tags_path,
          headers: User.first.create_new_auth_token,
          params: {
            tag: {
              name: ''
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(400)
        expect(res_body['message']).to include('Bad Request')
      end
    end
    context '[GET] /tags #tags#index' do
      it 'returns a valid 200 with valid request' do
        crt_tag
        get(
          api_v1_tags_path,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data'][0]['id']).to eq(crt_tag.id)
        expect(res_body['data'][0]['name']).to eq(crt_tag.name)
      end
      it 'returns a valid 404 when there is no tag' do
        get(
          api_v1_tags_path,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
    end
    context '[DELETE] /tags #tags#destroy' do
      it 'returns a valid 200 with valid request' do
        crt_tag
        before_tag_count = Tag.count
        delete(
          api_v1_tags_path + '/' + crt_tag.id.to_s,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(Tag.count).to eq(before_tag_count - 1)
      end
      it 'returns a valid 404 when there is no tag' do
        tag_id = crt_tag.id
        Tag.destroy_all
        delete(
          api_v1_tags_path + '/' + tag_id.to_s,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
    end
    context '[GET] /tags #tags#index_with_job_id' do
      it 'returns a valid 200 with valid request' do
        crt_tag
        get(
          tags_with_job_id_api_v1_tags_path + "?job_id=#{crt_job.id}",
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data'][0]['id']).to eq(crt_tag.id)
        expect(res_body['data'][0]['name']).to eq(crt_tag.name)
      end
      it 'returns a valid 404 when there is no tag in group' do
        group = create(:group)
        job = group.jobs.create(title: 'test2')
        get(
          tags_with_job_id_api_v1_tags_path + "?job_id=#{job.id}",
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
    end
  end
end
