# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stocks', type: :request do
  describe '/stocks' do
    login
    let(:bld_stock) { build(:stock) }
    let(:crt_stock) { create(:stock) }
    let(:member) { create(:member) }
    let(:another_user) { create(:user) }
    context '[POST] /stocks #stocks#create' do
      it 'returns a valid 201 with valid request' do
        bld_stock
        member
        post(
          api_v1_stocks_path,
          headers: User.first.create_new_auth_token,
          params: {
            stock: {
              job_id: bld_stock.job_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        stock = Stock.last
        expect(res_body['status']).to eq(201)
        expect(res_body['message']).to include('Created')
        expect(res_body['data']['id']).to eq(stock.id)
        expect(res_body['data']['user_id']).to eq(bld_stock.user_id)
        expect(res_body['data']['job_id']).to eq(bld_stock.job_id)
      end
      it 'returns an invalid 400 with duplicate stock request' do
        crt_stock
        member
        post(
          api_v1_stocks_path,
          headers: User.first.create_new_auth_token,
          params: {
            stock: {
              job_id: crt_stock.job_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(400)
        expect(res_body['message']).to include('Bad Request')
      end
      it 'returns an invalid 404  when job does not exist' do
        crt_stock
        member
        post(
          api_v1_stocks_path,
          headers: User.first.create_new_auth_token,
          params: {
            stock: {
              job_id: (crt_stock.job_id + 1)
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when job is not public and current_user is not member of job' do
        bld_stock
        post(
          api_v1_stocks_path,
          headers: User.first.create_new_auth_token,
          params: {
            stock: {
              job_id: bld_stock.job_id
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Acceptable')
      end
    end
    context '[GET] /stocks #stocks#index' do
      it 'returns a valid 200 with valid request' do
        crt_stock
        user = User.first
        stock_count = user.stocks.count
        member
        get(
          api_v1_stocks_path,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data'].length).to eq(stock_count)
        expect(res_body['data'][0]['id']).to eq(user.stock_jobs[0].id)
        expect(res_body['data'][0]['title']).to eq(user.stock_jobs[0].title)
        expect(res_body['data'][0]['description']).to eq(user.stock_jobs[0].description)
        expect(res_body['data'][0]['image']).to eq(user.stock_jobs[0].image)
        expect(res_body['data'][0]['is_public']).to eq(user.stock_jobs[0].is_public)
      end
      it 'returns an invalid 404  when job does not exist' do
        member
        get(
          api_v1_stocks_path,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
    end
    context '[DELETE] /stocks #stocks#destroy' do
      it 'returns a valid 200 with valid request' do
        crt_stock
        member
        delete(
          api_v1_stocks_path + '/' + crt_stock.id.to_s,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['id']).to eq(crt_stock.id)
        expect(res_body['data']['user_id']).to eq(crt_stock.user_id)
        expect(res_body['data']['job_id']).to eq(crt_stock.job_id)
      end
      it 'returns an invalid 404  when stock does not exist' do
        dummy_stock_id = crt_stock.id
        crt_stock.destroy
        delete(
          api_v1_stocks_path + '/' + dummy_stock_id.to_s,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406  when requested stock does not belong to current_user' do
        crt_stock
        delete(
          api_v1_stocks_path + '/' + crt_stock.id.to_s,
          headers: another_user.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
  end
end
