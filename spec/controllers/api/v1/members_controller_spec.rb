# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::MembersController, type: :controller do
  describe 'GET #create' do
    it 'returns http success' do
      get :create
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #destroy' do
    it 'returns http success' do
      get :destroy
      expect(response).to have_http_status(:success)
    end
  end
end
