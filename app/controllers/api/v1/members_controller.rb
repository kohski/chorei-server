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

        if member.group.members.count <= 1
          response_bad_request_with_custome_message(I18n.t('errors.format', attribute: I18n.t('activerecord.models.member'), message: I18n.t('errors.messages.last_member')))
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
        member_users = group.member_users
        if member_users.present?
          response_success(member_users)
        else
          response_not_found(member_users)
        end
      end

      def destroy_with_user_id_and_group_id
        member = Member.find_by(group_id: params[:group_id], user_id: member_params[:user_id])
        if member.present?
          response_success(member)
        else
          response_not_found(Member.name)
        end
      end

      private

      def member_params
        params.require(:member).permit(:email, :group_id, :user_id)
      end
    end
  end
end
