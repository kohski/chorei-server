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
        groups = Group.all
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

      private

      def group_params
        params.require(:group).permit(:name, :image)
      end

      def check_group_member
        group = Group.find_by(id: params[:id])
        if group.nil?
          response_not_found(Group.name)
          return
        end
        members = group.members.pluck(:user_id)
        response_not_found(Group.name) if members.index(current_api_v1_user.id).nil?
      end
    end
  end
end
