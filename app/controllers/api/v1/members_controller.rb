# frozen_string_literal: true

module Api
  module V1
    class MembersController < ApplicationController
      before_action :authenticate_api_v1_user!
      def create
        user = User.find_by(email: member_params[:email])
        if user.nil?
          response_not_found(User.name)
          return
        end

        group = Group.find_by(id: params[:group_id])
        if group.nil?
          response_not_found(Group.name)
          return
        end

        member = group.members.create(user_id: user.id)

        if member.valid?
          member.save
          response_created(member)
        else
          response_bad_request(member)
        end
      end

      def destroy
        member = Member.find_by(id: params[:id])
        if member.nil?
          response_not_found(Member.name)
          return
        end
        if member.destroy
          response_success(member)
        else
          response_bad_request(member)
        end
      end

      def index
        group = Group.find_by(id: params[:group_id])
        if group.nil?
          response_not_found(Group.name)
          return
        end
        members = Member.where(group_id: params[:group_id])
        if members.present?
          response_success(members)
        else
          response_not_found(members)
        end
      end

      private

      def member_params
        params.require(:member).permit(:email)
      end
    end
  end
end
