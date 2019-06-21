# frozen_string_literal: true

module Api
  module V1
    class AssignsController < ApplicationController
      before_action :authenticate_api_v1_user!
      def create
        job = Job.find_by(id: assign_params[:job_id])
        if job.nil?
          response_not_found(Job.name)
          return
        end

        member = Member.find_by(id: assign_params[:member_id])
        if member.nil?
          response_not_found(Member.name)
          return
        end

        if job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(User.name)
          return
        end

        if member.group.members.pluck(:id).index(member.user_id)
          response_not_acceptable(Member.name)
          return
        end

        assign = job.assigns.create(member_id: member.id)
        if assign.valid?
          response_created(assign)
        else
          response_bad_request(assign)
        end
      end

      def index
        assign_jobs = current_api_v1_user.members.map(&:assign_jobs).flatten
        if assign_jobs.present?
          response_success(assign_jobs)
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

        if assign.job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Assign.name)
          return
        end

        if assign.destroy
          response_success(assign)
        else
          response_bad_request(assign)
        end
      end

      def assign_members
        job = Job.find_by(id: params[:job_id])
        if job.nil?
          response_not_found(Job.name)
          return
        end
        members = job.assign_members
        user_ids = members.pluck(:user_id)
        users = user_ids.map do |user_id|
          User.find_by(id: user_id)
        end
        if users.present?
          response_success(users)
        else
          response_not_found(User.name)
        end
      end

      def create_assign_with_user_id
        job = Job.find_by(id: assign_params[:job_id])
        if job.nil?
          response_not_found(Job.name)
          return
        end
        if job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(User.name)
          return
        end
        user = User.find_by(id: assign_params[:user_id])
        if user.nil?
          response_not_found(User.name)
          return
        end
        if job.group.members.pluck(:user_id).index(user.id).nil?
          response_not_acceptable(User.name)
          return
        end
        member = job.group.members.find { |elm| elm.user_id == user.id }
        if member.nil?
          response_not_found(Member.name)
          return
        end
        assign = Assign.create(member_id: member.id, job_id: job.id)
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

        if job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(User.name)
          return
        end

        user = User.find_by(id: params[:user_id])
        if user.nil?
          response_not_found(User.name)
          return
        end

        if job.group.members.pluck(:user_id).index(user.id).nil?
          response_not_acceptable(User.name)
          return
        end

        member = job.group.members.find { |elm| elm.user_id == user.id }
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
    end
  end
end
