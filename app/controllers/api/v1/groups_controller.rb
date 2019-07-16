# frozen_string_literal: true

module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :check_group_member, only: %i[show destroy update]

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
        response_success(@group) if @group
      end

      def destroy
        if @group.nil?
          response_not_found(Group.name)
          return
        end
        response_success(@group) if @group.destroy
      end

      def update
        if @group.update(group_params)
          response_success(@group)
        else
          response_bad_request(@group)
        end
      end

      def show_group_id_with_job_id
        job = Job.find_by(id: params[:job_id])
        if job.nil?
          response_not_found(Job.name)
          return
        end
        unless Member.in_member?(job.group, current_api_v1_user)
          response_forbidden(job)
          return
        end
        response_success(job.group.id)
      end

      private

      def group_params
        params.require(:group).permit(:name, :image)
      end

      def check_group_member
        @group = Group.find_by(id: params[:id])
        if @group.nil?
          response_not_found(Group.name)
          return
        end
        unless Member.in_member?(@group, current_api_v1_user)
          response_forbidden(Member.nane)
          return
        end
        @group
      end
    end
  end
end
