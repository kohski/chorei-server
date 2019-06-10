# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Chorei API', type: :request do
  describe 'User, Auth' do
    let(:bld_user) { build(:user) }
    let(:crt_user) { create(:user) }
    context '[POST] /auth #auth/registrations#create' do
      it 'returns a valid 201 response' do
        post(
          api_v1_user_registration_path,
          params: {
            registration: {
              name: bld_user.name,
              email: bld_user.email,
              image: bld_user.image,
              description: bld_user.description,
              role: 0,
              password: bld_user.password
            }
          }
        )
        res_body = JSON.parse(response.body)
        target = User.last
        expect(res_body['status']).to eq('success')
        expect(res_body['data']['id']).to eq(target.id)
        expect(res_body['data']['provider']).to eq('email')
        expect(res_body['data']['uid']).to eq(target.email)
        expect(res_body['data']['image']).to eq(target.image)
        expect(res_body['data']['email']).to eq(target.email)
        expect(res_body['data']['description']).to eq(target.description)
        expect(res_body['data']['role']).to eq(target.role)
        # expect(Time.new(res_body['data']['created_at'])).to eq(Time.new(target.created_at))
        # expect(Time.new(res_body['data']['update_at'])).to eq(Time.new(target.updated_at))
      end

      it 'returns a invalid 422 when email has already exist' do
        crt_user
        post(
          api_v1_user_registration_path,
          params: {
            registration: {
              name: bld_user.name,
              email: crt_user.email,
              image: bld_user.image,
              description: bld_user.description,
              role: 0,
              password: bld_user.password
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq('error')
        expect(res_body['data']['id']).to eq(nil)
        expect(res_body['data']['provider']).to eq('email')
        expect(res_body['data']['uid']).to eq('')
        expect(res_body['data']['created_at']).to eq(nil)
        expect(res_body['data']['update_at']).to eq(nil)
        expect(res_body['data']['update_at']).to eq(nil)
        expect(res_body['errors']['email']).to include(I18n.t('errors.messages.taken'))
        expect(res_body['errors']['full_messages']).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.user.email'), message: I18n.t('errors.messages.taken')))
      end
    end

    context '[PUT] /auth #auth/registrations#update' do
      login
      it 'returns a valid 200 response' do
        user = User.first
        access_token = user.create_new_auth_token
        put(
          api_v1_user_registration_path,
          params: {
            registration: {
              name: 'updated_' + user.name,
              email: 'updated_' + user.email,
              image: user.image,
              description: 'updated_' + user.description,
              role: 0
            }
          },
          headers: access_token
        )
        res_body = JSON.parse(response.body)
        target = User.last
        expect(res_body['status']).to eq('success')
        expect(res_body['data']['id']).to eq(target.id)
        expect(res_body['data']['provider']).to eq('email')
        expect(res_body['data']['uid']).to eq(target.email)
        expect(res_body['data']['image']).to eq(target.image)
        expect(res_body['data']['email']).to eq(target.email)
        expect(res_body['data']['description']).to eq(target.description)
        expect(res_body['data']['role']).to eq(target.role)
      end
    end

    context '[GET] /api/v1/auth/validate_token #devise_token_auth/token_validations#validate_token' do
      login
      it 'returns a valid 200 response' do
        user = User.first
        get(
          api_v1_auth_validate_token_path,
          headers: user.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(response.headers['access-token']).to eq(request.headers['HTTP_ACCESS_TOKEN'])
        expect(response.headers['uid']).to eq(request.headers['HTTP_UID'])
        expect(response.headers['client']).to eq(request.headers['HTTP_CLIENT'])

        expect(res_body['success']).to eq(true)
        expect(res_body['data']['id']).to eq(user.id)
        expect(res_body['data']['provider']).to eq('email')
        expect(res_body['data']['uid']).to eq(user.email)
        expect(res_body['data']['image']).to eq(user.image)
        expect(res_body['data']['email']).to eq(user.email)
        expect(res_body['data']['description']).to eq(user.description)
        expect(res_body['data']['role']).to eq(user.role)
      end

      it 'returns an invalid 401 when with invalid_token' do
        get(
          api_v1_auth_validate_token_path,
          headers: {
            uid: 'invalid',
            'access-token': 'invalid',
            client: 'invalid'
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['success']).to eq(false)
      end
    end

    context '[POST]  /api/v1/auth/sign_in #devise_token_auth/sessions#create' do
      it 'returns a valid 200 response' do
        crt_user
        post(
          api_v1_user_session_path,
          params: {
            "email": crt_user.email,
            "password": crt_user.password
          }
        )
        expect(response.headers['access-token']).to be_present
        expect(response.headers['uid']).to be_present
        expect(response.headers['client']).to be_present
        expect(response.status).to eq(200)
      end

      it 'returns a valid 401 when password is invalid' do
        crt_user
        post(
          api_v1_user_session_path,
          params: {
            "email": crt_user.email,
            "password": 'invalid_password'
          }
        )
        expect(response.status).to eq(401)
        expect(response.headers['access-token']).to be_blank
        expect(response.headers['uid']).to be_blank
        expect(response.headers['client']).to be_blank
      end

      it 'returns a valid 401 when email is invalid' do
        crt_user
        post(
          api_v1_user_session_path,
          params: {
            "email": 'invalid@test.com',
            "password": crt_user.password
          }
        )
        expect(response.status).to eq(401)
        expect(response.headers['access-token']).to be_blank
        expect(response.headers['uid']).to be_blank
        expect(response.headers['client']).to be_blank
      end
    end

    context '[PUT] /api/v1/auth/password #devise_token_auth/passwords#update' do
      it 'returns a valid 200 response' do
        crt_user
        put(
          api_v1_user_password_path,
          headers: crt_user.create_new_auth_token,
          params: {
            password: 'updated_password',
            password_confirmation: 'updated_password'
          }
        )
        expect(response.status).to eq(200)
        expect(response.headers['access-token']).to be_present
        expect(response.headers['uid']).to be_present
        expect(response.headers['client']).to be_present
      end

      it 'returns a valid 401 when token is invalid' do
        put(
          api_v1_user_password_path,
          headers: {
            uid: 'invalid',
            client: 'invalid',
            'access-token': 'invalid'
          },
          params: {
            password: 'updated_password',
            password_confirmation: 'updated_password'
          }
        )
        expect(response.status).to eq(401)
        expect(response.headers['access-token']).to be_blank
        expect(response.headers['uid']).to be_blank
        expect(response.headers['client']).to be_blank
      end
    end

    context '[DELETE] /api/v1/auth/sign_out #devise_token_auth/sessions#destroy' do
      it 'returns a valid 200 response' do
        crt_user
        access_token = crt_user.create_new_auth_token
        delete(
          destroy_api_v1_user_session_path,
          headers: access_token
        )
        expect(response.status).to eq(200)

        get(
          api_v1_auth_validate_token_path,
          headers: access_token
        )
        expect(response.status).to eq(401)
      end

      it 'returns a valid 404 when request token is invalid' do
        crt_user
        delete(
          destroy_api_v1_user_session_path,
          headers: {
            uid: 'invalid',
            client: 'invalid',
            'access-token': 'invalid'
          }
        )
        expect(response.status).to eq(404)
      end
    end

    context '[DELETE] /api/v1/auth #auth/registrations#destroy' do
      it 'returns a valid 200 response' do
        crt_user
        before_user_count = User.count
        delete(
          api_v1_user_registration_path,
          headers: crt_user.create_new_auth_token
        )
        expect(response.status).to eq(200)
        expect(User.count).to eq(before_user_count - 1)
      end
      it 'returns a valid [***] when [***]' do
        crt_user
        before_user_count = User.count
        delete(
          api_v1_user_registration_path,
          headers: {
            uid: 'invalid',
            client: 'invalid',
            'access-token': 'invalid'
          }
        )
        expect(response.status).to eq(404)
        expect(User.count).to eq(before_user_count)
      end
    end
  end
end
