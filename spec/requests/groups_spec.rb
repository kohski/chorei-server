# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Groups', type: :request do
  login
  let(:crt_group) { create(:group) }
  let(:crt_group_second) { create(:group) }
  let(:bld_group) { build(:group) }
  context '[POST] /groups #groups#create' do
    it 'returns a valid 201 with valid request' do
      post(
        api_v1_groups_path,
        headers: User.first.create_new_auth_token,
        params: {
          group: {
            name: 'test',
            image: 'data:image/png;base64,iVBORw'
          }
        }
      )
      res_body = JSON.parse(response.body)
      group = Group.last
      expect(res_body['status']).to eq(201)
      expect(res_body['message']).to include('Created')
      expect(res_body['data']['id']).to eq(group.id)
      expect(res_body['data']['name']).to eq(group.name)
      expect(res_body['data']['image']).to eq(group.image)
    end
    it 'returns an invalid 400 without group name' do
      post(
        api_v1_groups_path,
        headers: User.first.create_new_auth_token,
        params: {
          group: {
            name: '',
            image: 'data:image/png;base64,iVBORw'
          }
        }
      )
      res_body = JSON.parse(response.body)
      expect(res_body['status']).to eq(400)
      expect(res_body['message']).to include('Bad Request')
      expect(res_body['data']).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.group.name'), message: I18n.t('errors.messages.blank')))
    end
  end
  context '[GET] /groups #groups#index' do
    it 'returns a valid 200 with valid request' do
      crt_group
      crt_group_second
      get(
        api_v1_groups_path,
        headers: User.first.create_new_auth_token
      )
      res_body = JSON.parse(response.body)
      group = Group.find_by(id: res_body['data'][0]['id'])
      expect(res_body['status']).to eq(200)
      expect(res_body['message']).to include('Success')
      expect(res_body['data'].length).to eq(2)
      expect(res_body['data'][0]['id']).to eq(group.id)
      expect(res_body['data'][0]['name']).to eq(group.name)
      expect(res_body['data'][0]['image']).to eq(group.image)
    end
    it 'returns an invalid 404 when current_user has no group' do
      get(
        api_v1_groups_path,
        headers: User.first.create_new_auth_token
      )
      res_body = JSON.parse(response.body)
      expect(res_body['status']).to eq(404)
      expect(res_body['message']).to include('Not Found')
    end
  end

  context '[PUT] /groups/{group_id} #groups#update' do
    let(:another_user) { create(:user) }
    it 'returns a valid 200 with valid request' do
      group = crt_group
      group.members.create(user_id: another_user.id)
      update_info = {
        name: 'updated_name',
        image: 'data:image/png;base64,iVBORw',
        owner_id: another_user.id
      }
      put(
        api_v1_groups_path + '/' + crt_group.id.to_s,
        headers: User.first.create_new_auth_token,
        params: {
          group: update_info
        }
      )
      res_body = JSON.parse(response.body)
      expect(res_body['status']).to eq(200)
      expect(res_body['message']).to include('Success')
      expect(res_body['data']['owner_id']).to eq(update_info[:owner_id])
      expect(res_body['data']['name']).to eq(update_info[:name])
      expect(res_body['data']['image']).to eq(update_info[:image])
    end
    it 'returns an invalid 404 when there is no target group ' do
      crt_group
      update_info = {
        name: 'updated_name',
        image: 'data:image/png;base64,iVBORw',
        owner_id: another_user.id
      }
      Group.destroy_all
      put(
        api_v1_groups_path + '/' + crt_group.id.to_s,
        headers: User.first.create_new_auth_token,
        params: {
          group: update_info
        }
      )
      res_body = JSON.parse(response.body)
      expect(res_body['status']).to eq(404)
      expect(res_body['message']).to include('Not Found')
    end
    it 'returns an invalid 400 with invalid request ' do
      crt_group
      update_info = {
        name: '',
        image: 'datbase64iVBORw',
        owner_id: (User.last.id + 1)
      }
      put(
        api_v1_groups_path + '/' + crt_group.id.to_s,
        headers: User.first.create_new_auth_token,
        params: {
          group: update_info
        }
      )
      res_body = JSON.parse(response.body)
      expect(res_body['status']).to eq(400)
      expect(res_body['message']).to include('Bad Request')
      expect(res_body['data']).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.group.name'), message: I18n.t('errors.messages.blank')))
      expect(res_body['data']).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.group.owner'), message: I18n.t('errors.messages.blank')))
      expect(res_body['data']).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.group.image'), message: I18n.t('errors.messages.wrong_mime_type')))
    end
  end

  context '[GET] /groups/{group_id} #groups#show' do
    it 'returns a valid 200 with valid request' do
      crt_group
      get(
        api_v1_groups_path + '/' + crt_group.id.to_s,
        headers: User.first.create_new_auth_token
      )
      res_body = JSON.parse(response.body)
      expect(res_body['status']).to eq(200)
      expect(res_body['message']).to include('Success')
    end
    it 'returns an invalid 404 when there is no target group ' do
      group_id = crt_group.id.to_s
      Group.destroy_all
      get(
        api_v1_groups_path + '/' + group_id,
        headers: User.first.create_new_auth_token
      )
      res_body = JSON.parse(response.body)
      expect(res_body['status']).to eq(404)
      expect(res_body['message']).to include('Not Found')
    end
  end

  context '[DELETE] /groups/{group_id} #groups#destroy' do
    it 'returns a valid 200 with valid request' do
      crt_group
      group_counts_before_delete = Group.count
      delete(
        api_v1_groups_path + '/' + crt_group.id.to_s,
        headers: User.first.create_new_auth_token
      )
      res_body = JSON.parse(response.body)
      expect(res_body['status']).to eq(200)
      expect(res_body['message']).to include('Success')
      expect(Group.count).to eq(group_counts_before_delete - 1)
    end
    it 'returns an invalid 404 when there is no target group ' do
      target_id = crt_group.id.to_s
      Group.destroy_all
      delete(
        api_v1_groups_path + '/' + target_id,
        headers: User.first.create_new_auth_token
      )
      res_body = JSON.parse(response.body)
      expect(res_body['status']).to eq(404)
      expect(res_body['message']).to include('Not Found')
    end
  end
end
