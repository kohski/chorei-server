# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Jobs', type: :request do
  describe '/jobs' do
    login
    let(:bld_job) { build(:job) }
    let(:crt_job) { create(:job) }
    let(:crt_public_job) { create(:job, :public) }
    let(:member) { create(:member) }
    context '[POST] /jobs #jobs#create' do
      it 'returns a valid 201 with valid request' do
        bld_job
        member
        post(
          api_v1_group_jobs_path(group_id: bld_job.group_id),
          headers: User.first.create_new_auth_token,
          params: {
            job: {
              title: bld_job.title,
              image: bld_job.image,
              description: bld_job.description,
              is_public: bld_job.is_public
            }
          }
        )
        res_body = JSON.parse(response.body)
        job = Job.last
        expect(res_body['status']).to eq(201)
        expect(res_body['message']).to include('Created')
        expect(res_body['data']['id']).to eq(job.id)
        expect(res_body['data']['title']).to eq(job.title)
        expect(res_body['data']['image']).to eq(job.image)
        expect(res_body['data']['description']).to eq(job.description)
        expect(res_body['data']['is_public']).to eq(job.is_public)
      end
      it 'returns an invalid 400 with invalid params' do
        bld_job
        member
        post(
          api_v1_group_jobs_path(group_id: bld_job.group_id),
          headers: User.first.create_new_auth_token,
          params: {
            job: {
              title: '',
              image: 'invalid',
              description: 'a' * 1201
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(400)
        expect(res_body['message']).to include('Bad Request')
        expect(res_body['data']).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.job.title'), message: I18n.t('errors.messages.blank')))
        expect(res_body['data']).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.job.description'), message: I18n.t('errors.messages.too_long', count: 1200)))
        expect(res_body['data']).to include(I18n.t('errors.format', attribute: I18n.t('activerecord.attributes.job.image'), message: I18n.t('errors.messages.wrong_mime_type')))
      end
      it 'returns an invalid 404 when job does not exsit' do
        bld_job
        member
        post(
          api_v1_group_jobs_path(group_id: (bld_job.group_id + 1)),
          headers: User.first.create_new_auth_token,
          params: {
            job: {
              title: bld_job.title,
              image: bld_job.image,
              description: bld_job.description
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when current user is not member of the group' do
        group = Group.create(name: 'another group')
        post(
          api_v1_group_jobs_path(group_id: group.id),
          headers: User.first.create_new_auth_token,
          params: {
            job: {
              title: bld_job.title,
              image: bld_job.image,
              description: bld_job.description
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[GET] /jobs #jobs#index' do
      it 'returns a valid 201 with valid request' do
        crt_job
        member
        get(
          api_v1_group_jobs_path(group_id: crt_job.group_id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        job = Job.last
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data'][0]['id']).to eq(job.id)
        expect(res_body['data'][0]['title']).to eq(job.title)
        expect(res_body['data'][0]['image']).to eq(job.image)
        expect(res_body['data'][0]['description']).to eq(job.description)
        expect(res_body['data'][0]['is_public']).to eq(job.is_public)
      end
      it 'returns an invalid 404 when job does not exsit' do
        group = crt_job.group
        member
        group.jobs.destroy_all
        get(
          api_v1_group_jobs_path(group_id: group.id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when current user is not member of the group' do
        group = crt_job.group
        another_group = Group.create(name: 'another_group')
        group.jobs.destroy_all
        get(
          api_v1_group_jobs_path(group_id: another_group.id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[GET] /jobs/{job_id} #jobs#show' do
      it 'returns a valid 201 with valid request' do
        crt_job
        member
        get(
          api_v1_job_path(crt_job),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        job = Job.last
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['id']).to eq(job.id)
        expect(res_body['data']['title']).to eq(job.title)
        expect(res_body['data']['image']).to eq(job.image)
        expect(res_body['data']['description']).to eq(job.description)
        expect(res_body['data']['is_public']).to eq(job.is_public)
      end
      it 'returns an invalid 404 when job does not exsit' do
        job_id = crt_job
        Job.destroy_all
        get(
          api_v1_job_path(job_id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when job does not exsit' do
        another_group = Group.create(name: 'another_group')
        another_job = another_group.jobs.create(title: 'another_job')
        get(
          api_v1_job_path(another_job),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[PUT] /jobs/{job_id} #jobs#update' do
      it 'returns a valid 201 with valid request' do
        crt_job
        member
        put(
          api_v1_job_path(crt_job),
          headers: User.first.create_new_auth_token,
          params: {
            job: {
              title: crt_job.title + '_updated',
              image: crt_job.image + '_updated',
              description: crt_job.description + '_updated',
              is_public: !crt_job.is_public
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data']['id']).to eq(crt_job.id)
        expect(res_body['data']['title']).to eq(crt_job.title + '_updated')
        expect(res_body['data']['image']).to eq(crt_job.image + '_updated')
        expect(res_body['data']['description']).to eq(crt_job.description + '_updated')
        expect(res_body['data']['is_public']).to eq(!crt_job.is_public)
      end
      it 'returns an invalid 404 when job does not exsit' do
        job_id = crt_job.id
        Job.destroy_all
        put(
          api_v1_job_path(job_id),
          headers: User.first.create_new_auth_token,
          params: {
            job: {
              title: bld_job.title + '_updated',
              image: bld_job.image + '_updated',
              description: bld_job.description + '_updated',
              is_public: !bld_job.is_public
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when job belongs to group whilch current user is not member' do
        another_group = Group.create(name: 'another_group')
        another_job = another_group.jobs.create(title: 'another_job')
        put(
          api_v1_job_path(another_job),
          headers: User.first.create_new_auth_token,
          params: {
            job: {
              title: bld_job.title + '_updated',
              image: bld_job.image + '_updated',
              description: bld_job.description + '_updated',
              is_public: !bld_job.is_public
            }
          }
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[DELETE] /jobs/{job_id} #jobs#destroy' do
      it 'returns a valid 201 with valid request' do
        crt_job
        member
        before_job_count = Job.count
        delete(
          api_v1_job_path(crt_job),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(Job.count).to eq(before_job_count - 1)
        expect(res_body['data']['id']).to eq(crt_job.id)
        expect(res_body['data']['title']).to eq(crt_job.title)
        expect(res_body['data']['image']).to eq(crt_job.image)
        expect(res_body['data']['description']).to eq(crt_job.description)
        expect(res_body['data']['is_public']).to eq(crt_job.is_public)
      end
      it 'returns an invalid 404 when job does not exsit' do
        dummy_job_id = crt_job.id
        Job.destroy_all
        delete(
          api_v1_job_path(id: dummy_job_id),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
      it 'returns an invalid 406 when job belongs to group whilch current user is not member' do
        another_group = Group.create(name: 'another_group')
        another_job = another_group.jobs.create(title: 'another_job')
        delete(
          api_v1_job_path(another_job),
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(406)
        expect(res_body['message']).to include('Not Acceptable')
      end
    end
    context '[GET] /jobs/public_jobs #jobs#public_jobs' do
      it 'returns a valid 201 with valid request' do
        crt_job
        member
        crt_public_job
        get(
          api_v1_public_jobs_path,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(200)
        expect(res_body['message']).to include('Success')
        expect(res_body['data'].length).to eq(Job.where(is_public: true).count)
        expect(res_body['data'][0]['id']).to eq(crt_public_job.id)
        expect(res_body['data'][0]['title']).to eq(crt_public_job.title)
        expect(res_body['data'][0]['image']).to eq(crt_public_job.image)
        expect(res_body['data'][0]['description']).to eq(crt_public_job.description)
        expect(res_body['data'][0]['is_public']).to eq(crt_public_job.is_public)
      end
      it 'returns an invalid 404 when job does not exsit' do
        crt_job
        member
        get(
          api_v1_public_jobs_path,
          headers: User.first.create_new_auth_token
        )
        res_body = JSON.parse(response.body)
        expect(res_body['status']).to eq(404)
        expect(res_body['message']).to include('Not Found')
      end
    end
  end
end
