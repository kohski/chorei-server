# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Members', type: :request do
  describe 'GET /members' do
    login
    let(:bld_member) { build(:member) }
    let(:crt_member) { create(:member) }
    let(:user) { create(:user) }
    context '[POST] /members #members#create' do
      it 'returns a valid 201 with valid request' do
        bld_member
        another_user = FactoryBot.create(:user)
        post(
          api_v1_members_path,
          headers: User.first.create_new_auth_token,
          params: {
            member: {
              user_id: another_user.id,
              group_id: bld_member.group_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        member = Member.last
        expect(res_body['status']).to eq(201)
        expect(res_body['message']).to include('Created')
        expect(res_body['data']['id']).to eq(member.id)
        expect(res_body['data']['user_id']).to eq(member.user_id)
        expect(res_body['data']['group_id']).to eq(member.group_id)
      end

      it 'returns an invalid 404 when user does not exist' do
        bld_member
        post(
          api_v1_members_path,
          headers: User.first.create_new_auth_token,
          params: {
            member: {
              user_id: bld_member.user_id,
              group_id: (bld_member.group_id + 1)
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(400)
        expect(res_body['message']).to include('Bad Request')
        expect(res_body['data']).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.member.group'), message: I18n.t('errors.messages.blank')))
      end
      it 'returns an invalid 404 when group does not exist' do
        bld_member
        post(
          api_v1_members_path,
          headers: User.first.create_new_auth_token,
          params: {
            member: {
              user_id: (bld_member.user_id + 1),
              group_id: bld_member.group_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(400)
        expect(res_body['message']).to include('Bad Request')
        expect(res_body['data']).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.member.user'), message: I18n.t('errors.messages.blank')))
      end
    end
    context '[DELETE] /membres #membres#destroy' do
      it 'returns a valid 201 with valid request' do
        crt_member
        delete(
          api_v1_members_path + '/' + crt_member.id.to_s,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['id']).to eq(crt_member.id)
        expect(res_body['data']['user_id']).to eq(crt_member.user_id)
        expect(res_body['data']['group_id']).to eq(crt_member.group_id)
      end
      it 'returns an invalid 404 when user does not exist' do
        member_id = crt_member.id
        Member.destroy_all
        delete(
          api_v1_members_path + '/' + member_id.to_s,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Member is Not Found')
      end
    end
  end
end
