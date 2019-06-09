# frozen_string_literal: true

require 'rails_helper'
require 'swagger_helper'

RSpec.describe 'Chorei API', type: :request do
  path '/auth' do
    post 'Create User' do
      tags 'Users'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string }
        },
        required: %w[title email password]
      }
      response '201', 'User Sign up' do
        user = FactoryBot.build(:user)
        data = {
          "id": 2,
          "provider": 'email',
          "uid": user.email,
          "allow_password_change": false,
          "name": nil,
          "image": nil,
          "email": user.email,
          "description": nil,
          "role": 0,
          "created_at": '2019-06-09T15:20:27.985+09:00',
          "updated_at": '2019-06-09T15:20:28.237+09:00'
        }
        it 'returns a vlalid 201 response' do
          post(
            api_v1_user_registration_path,
            params: {
              registration: {
                name: user.name,
                email: user.email,
                password: user.password
              }
            },
            headers: {
              'access-token': '',
              client: '',
              uid: ''
            }
          )
          registered_user = User.last
          expect(registered_user.name).to eq(user.name)
          expect(registered_user.email).to eq(user.email)
        end
        examples response_formatter(201, 'Created Group', data)
      end
    end
  end
end
