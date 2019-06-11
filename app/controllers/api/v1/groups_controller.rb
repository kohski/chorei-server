# frozen_string_literal: true

module Api
  module V1
    class GroupsController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        group = current_api_v1_user.groups.create(group_params)
        if group.valid?
          response_created(group)
          Member.auto_create_owner_as_member(group)
        else
          response_bad_request(group)
        end
      end

      def index
        groups = current_api_v1_user.groups
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
        params.require(:group).permit(:name, :image, :owner_id)
      end
    end
  end
end
