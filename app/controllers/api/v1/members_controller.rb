# frozen_string_literal: true

module Api
  module V1
    class MembersController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :set_group, only: %i[create index]

      def create
        user = User.find_by(email: member_params[:email])
        if user.nil?
          response_not_found(User.name)
          return
        end

        if @group.nil?
          response_not_found(Group.name)
          return
        end

        member = @group.members.create(user_id: user.id)

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
        if Member.last_member?(member)
          response_bad_request_with_custome_message(I18n.t('errors.format', attribute: I18n.t('activerecord.models.member'), message: I18n.t('errors.messages.last_member')))
          return
        end
        if member.is_owner
          response_bad_request_with_custome_message(I18n.t('errors.format', attribute: I18n.t('activerecord.models.member'), message: I18n.t('errors.messages.owner')))
          return
        end
        response_success(member) if member.destroy
      end

      def index
        if @group.nil?
          response_not_found(Group.name)
          return
        end
        users = @group.member_users.map do |user|
          user.attributes.slice('id', 'email', 'name', 'image', 'description')
        end
        users_with_member = users.map do |user|
          member = Member.find_by(group_id: @group.id, user_id: user['id'])
          user.merge(member: member)
        end
        if users_with_member.present?
          response_success(users_with_member)
        else
          response_not_found(users_with_member)
        end
      end

      def update
        member = Member.find_by(id: params[:id])
        if member.nil?
          response_not_found(Member.name)
          return
        end
        response_success(member) if member.update(member_params)
      end

      def destroy_with_user_id_and_group_id
        member = Member.find_by(group_id: params[:group_id], user_id: params[:user_id])

        if member.nil?
          response_not_found(Member.name)
          return
        end

        if Member.last_member?(member)
          response_bad_request_with_custome_message(I18n.t('errors.format', attribute: I18n.t('activerecord.models.member'), message: I18n.t('errors.messages.last_member')))
          return
        end

        if member.is_owner
          response_bad_request_with_custome_message(I18n.t('errors.format', attribute: I18n.t('activerecord.models.member'), message: I18n.t('errors.messages.owner')))
          return
        end

        member.destroy
        response_success(member)
      end

      private

      def member_params
        params.require(:member).permit(:id, :email, :group_id, :user_id, :is_owner)
      end

      def set_group
        @group = Group.find_by(id: params[:group_id])
      end
    end
  end
end
