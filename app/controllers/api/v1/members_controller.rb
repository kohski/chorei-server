# frozen_string_literal: true

module Api
  module V1
    class MembersController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        already_existed_member = Member.duplicate_check(member_params)
        if already_existed_member.present?
          response_success(already_existed_member)
          return
        end
        member = Member.new(member_params)
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

      private

      def member_params
        params.require(:member).permit(:user_id, :group_id)
      end
    end
  end
end
