# frozen_string_literal: true

module Api
  module V1
    class JobsController < ApplicationController
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
        job = group.jobs.build(job_params)
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

        if job.update(job_params)
          response_success(job)
        else
          response_bad_request(job)
        end
      end

      def public_jobs
        jobs = Job.where(is_pubclic: true)
        if jobs.present?
          response_success(jobs)
        else
          response_not_found(Job.name)
        end
      end

      private

      def job_params
        params.require(:job).permit(:title, :description, :image, :is_public)
      end
    end
  end
end
