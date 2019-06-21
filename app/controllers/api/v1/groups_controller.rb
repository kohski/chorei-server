# frozen_string_literal: true

module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :check_group_member, only: %i[show destroy]

      def create
        group = Group.create(group_params)
        if group.valid?
          response_created(group)
          group.join_current_user_to_member(current_api_v1_user)
        else
          response_bad_request(group)
        end
      end

      def index
        groups = current_api_v1_user.member_groups
        if groups.present?
          response_success(groups)
        else
          response_not_found(Group.name)
        end
      end

      def show
        group = Group.find_by(id: params[:id])

        if group
          response_success(group)
        else
          response_not_found(Group.name)
        end
      end

      def destroy
        group = Group.find_by(id: params[:id])
        if group.nil?
          response_not_found(Group.name)
          return
        end
        if group.destroy
          response_success(group)
        else
          response_bad_request(group)
        end
      end

      def update
        group = Group.find_by(id: params[:id])
        if group.nil?
          response_not_found(Group.name)
          return
        end
        if group.update(group_params)
          response_success(group)
        else
          response_bad_request(group)
        end
      end

      def group_id_with_job_id
        job = Job.find_by(id: group_params[:job_id])
        if job.nil?
          response_not_found(Job.name)
          return
        end
        if job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(job)
          return
        end

        response_success(job.group.id)
      end

      private

      def group_params
        params.require(:group).permit(:name, :image, :job_id)
      end

      def check_group_member
        group = Group.find_by(id: params[:id])
        if group.nil?
          response_not_found(Group.name)
          return
        end
        members = group.members.pluck(:user_id)
        response_not_acceptable(Group.name) if members.index(current_api_v1_user.id).nil?
      end
    end
  end
end
