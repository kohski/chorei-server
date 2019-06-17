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

      private

      def assign_params
        params.require(:assign).permit(:job_id, :member_id)
      end
    end
  end
end
