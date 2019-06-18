# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Members', type: :request do
  describe '/members' do
    login
    let(:bld_member) { build(:member) }
    let(:crt_member) { create(:member) }
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    context '[POST] /members #members#create' do
      it 'returns a valid 201 with valid request' do
        bld_member
        another_user = FactoryBot.create(:user)
        post(
          api_v1_group_members_path(group_id: bld_member.group_id),
          headers: User.first.create_new_auth_token,
          params: {
            member: {
              email: another_user.email,
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
        dummy_email = another_user.email
        another_user.destroy
        bld_member
        post(          
          api_v1_group_members_path(group_id: bld_member.group_id),
          headers: User.first.create_new_auth_token,
          params: {
            member: {
              email: dummy_email
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 404 when group does not exist' do
        bld_member
        post(
          api_v1_group_members_path(group_id: (bld_member.group_id + 1)),
          headers: User.first.create_new_auth_token,
          params: {
            member: {
              email: bld_member.user.email,
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
    end
    context '[DELETE] /membres #membres#destroy' do
      it 'returns a valid 201 with valid request' do
        crt_member
        delete(
          api_v1_member_path(id: crt_member.id),
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
          api_v1_member_path(id: member_id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Member is Not Found')
      end
    end
  end
end
