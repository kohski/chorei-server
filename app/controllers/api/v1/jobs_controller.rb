# frozen_string_literal: true

module Api
  module V1
    class JobsController < ApplicationController
      before_action :authenticate_api_v1_user!
      def create
        group = Group.find_by(id: params[:group_id])
        if group.nil?
          response_not_found(Group.name)
          return
        end
        if group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Group.name)
          return
        end

        begin
          job = group.jobs.build(job_params)
        rescue StandardError
          response_bad_request(Job.name)
          return
        end

        if job.save
          response_created(job)
        else
          response_bad_request(job)
        end
      end

      def index
        group = Group.find_by(id: params[:group_id])
        if group.nil?
          response_not_found(Group.name)
          return
        end
        if group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Group.name)
          return
        end
        jobs = group.jobs
        if jobs.present?
          response_success(jobs)
        else
          response_not_found(Job.name)
        end
      end

      def show
        job = Job.find_by(id: params[:id])
        if job.nil?
          response_not_found(Job.name)
          return
        end

        if job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Group.name)
          return
        end

        if job.present?
          response_success(job)
        else
          response_not_found(Job.name)
        end
      end

      def destroy
        job = Job.find_by(id: params[:id])
        if job.nil?
          response_not_found(Job.name)
          return
        end

        if job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Group.name)
          return
        end

        if job.destroy
          response_success(job)
        else
          response_bad_request(job)
        end
      end

      def update
        job = Job.find_by(id: params[:id])
        if job.nil?
          response_not_found(Job.name)
          return
        end

        if job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Group.name)
          return
        end

        begin
          job.update(job_params)
          response_success(job)
        rescue StandardError
          response_bad_request(job)
        end
      end

      def index_public_jobs
        jobs = Job.where(is_public: true)
        return_jobs = []
        jobs.each do |job|
          job_hash = job.attributes
          step_hashs = []
          job.steps.each do |step|
            step_hashs << step.attributes
          end
          job_hash_with_steps = job_hash.merge(steps: step_hashs)
          return_jobs << job_hash_with_steps
        end

        if jobs.present?
          response_success(return_jobs)
        else
          response_not_found(Job.name)
        end
      end

      def index_assigned_jobs
        assigned_jobs = current_api_v1_user.members.map(&:assign_jobs).flatten
        if assigned_jobs.present?
          response_success(assigned_jobs)
        else
          response_not_found(Job.name)
        end
      end

      private

      def job_params
        params.require(:job).permit(:title, :description, :image, :is_public, :frequency, :repeat_times, :base_start_at, :base_end_at)
      end
    end
  end
end
