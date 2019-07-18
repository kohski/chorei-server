# frozen_string_literal: true

module Api
  module V1
    class JobsController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :set_group, only: %i[create index]
      before_action :set_job, only: %i[show destroy update]

      def create
        if @group.nil?
          response_not_found(Group.name)
          return
        end
        unless Member.in_member?(@group, current_api_v1_user)
          response_forbidden(Group.name)
          return
        end

        begin
          job = @group.jobs.build(job_params)
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
        if @group.nil?
          response_not_found(Group.name)
          return
        end
        unless Member.in_member?(@group, current_api_v1_user)
          response_forbidden(Group.name)
          return
        end
        jobs = @group.jobs
        jobs_with_tags = Job.jobs_with_tags(jobs)
        jobs_with_assigns = Job.jobs_with_assigns(jobs, jobs_with_tags)
        if jobs_with_assigns.present?
          response_success(jobs_with_assigns)
        else
          response_not_found(Job.name)
        end
      end

      def show
        if @job.nil?
          response_not_found(Job.name)
          return
        end
        unless Member.in_member?(@job.group, current_api_v1_user)
          response_forbidden(Group.name)
          return
        end
        response_success(@job) if @job.present?
      end

      def destroy
        if @job.nil?
          response_not_found(Job.name)
          return
        end

        unless Member.in_member?(@job.group, current_api_v1_user)
          response_forbidden(Group.name)
          return
        end

        response_success(@job) if @job.destroy
      end

      def update
        if @job.nil?
          response_not_found(Job.name)
          return
        end

        unless Member.in_member?(@job.group, current_api_v1_user)
          response_forbidden(Group.name)
          return
        end

        begin
          @job.update(job_params)
          response_success(@job)
        rescue StandardError
          response_bad_request(@job)
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
        assigned_jobs = Job.assigned_jobs_with_user(current_api_v1_user)
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

      def set_group
        @group = Group.find_by(id: params[:group_id])
      end

      def set_job
        @job = Job.find_by(id: params[:id])
      end
    end
  end
end
