# frozen_string_literal: true

module Api
  module V1
    class AssignsController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :set_job, only: %i[create create_assign_with_user_id]

      def create
        if @job.nil?
          response_not_found(Job.name)
          return
        end

        member = Member.find_by(id: assign_params[:member_id])
        if member.nil?
          response_not_found(Member.name)
          return
        end

        unless Member.in_member?(@job.group, current_api_v1_user)
          response_forbidden(User.name)
          return
        end

        assign = @job.assigns.create(member_id: member.id)
        if assign.valid?
          response_created(assign)
        else
          response_bad_request(assign)
        end
      end

      def index
        assigned_jobs = Job.assigned_jobs_with_user(current_api_v1_user)
        if assigned_jobs.present?
          response_success(assigned_jobs)
        else
          response_not_found(Assign.name)
        end
      end

      def destroy
        assign = Assign.find_by(id: params[:id])
        if assign.nil?
          response_not_found(Assign.name)
          return
        end

        unless Member.in_member?(assign.job.group, current_api_v1_user)
          response_forbidden(Assign.name)
          return
        end

        if assign.destroy
          response_success(assign)
        else
          response_bad_request(assign)
        end
      end

      def index_assign_members
        job = Job.find_by(id: params[:job_id])
        if job.nil?
          response_not_found(Job.name)
          return
        end
        users = User.assigned_users_with_job(job)
        if users.present?
          response_success(users)
        else
          response_not_found(User.name)
        end
      end

      def create_assign_with_user_id
        # job = Job.find_by(id: assign_params[:job_id])
        if @job.nil?
          response_not_found(Job.name)
          return
        end
        unless Member.in_member?(@job.group, current_api_v1_user)
          response_forbidden(User.name)
          return
        end
        user = User.find_by(id: assign_params[:user_id])
        if user.nil?
          response_not_found(User.name)
          return
        end
        unless Member.in_member?(@job.group, user)
          response_forbidden(User.name)
          return
        end
        member = Member.find_by_job_and_user(@job, user)
        if member.nil?
          response_not_found(Member.name)
          return
        end
        assign = Assign.create(member_id: member.id, job_id: @job.id)
        if assign.valid?
          response_success(assign)
        else
          response_bad_request(assign)
        end
      end

      def destroy_assign_with_user_id
        job = Job.find_by(id: params[:job_id])
        if job.nil?
          response_not_found(Job.name)
          return
        end

        unless Member.in_member?(job.group, current_api_v1_user)
          response_forbidden(User.name)
          return
        end

        user = User.find_by(id: params[:user_id])
        if user.nil?
          response_not_found(User.name)
          return
        end

        unless Member.in_member?(job.group, user)
          response_forbidden(User.name)
          return
        end

        member = Member.find_by_job_and_user(job, user)
        if member.nil?
          response_not_found(Member.name)
          return
        end

        assign = Assign.find_by(member_id: member.id, job_id: job.id)
        if assign.nil?
          response_not_found(Assign.name)
          return
        end

        if assign.destroy
          response_success(assign)
        else
          response_bad_request(assign)
        end
      end

      private

      def assign_params
        params.require(:assign).permit(:job_id, :member_id, :user_id)
      end

      def set_job
        @job = Job.find_by(id: assign_params[:job_id])
      end
    end
  end
end
