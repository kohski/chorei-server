# frozen_string_literal: true

module Api
  module V1
    class TagsController < ApplicationController
      before_action :authenticate_api_v1_user!
      def create
        tag = Tag.create(tag_params)
        if tag.valid?
          response_created(tag)
        else
          response_bad_request(tag)
        end
      end

      def index
        group = Group.find_by(id: params[:group_id])
        if group.nil?
          response_not_found(Group.name)
          return
        end
        tags = group.tags
        if tags.present?
          response_success(tags)
        else
          response_not_found(Tag.name)
        end
      end

      def destroy
        tag = Tag.find_by(id: params[:id])

        if tag.nil?
          response_not_found(Tag.name)
          return
        end

        response_success(tag) if tag.destroy
      end

      def index_with_job_id
        job = Job.find_by(id: params[:job_id])
        if job.nil?
          response_not_found(Job.name)
          return
        end

        unless Member.in_member?(job.group, current_api_v1_user)
          response_forbidden(User.name)
          return
        end

        tags = job.group.tags
        if tags.present?
          response_success(tags)
        else
          response_not_found(Tag.name)
        end
      end

      def create_with_job_id
        job = Job.find_by(id: params[:job_id])
        if job.nil?
          response_not_found(Job.name)
          return
        end

        unless Member.in_member?(job.group, current_api_v1_user)
          response_forbidden(User.name)
          return
        end

        tag = job.group.tags.create(tag_params)
        if tag.valid?
          response_created(tag)
        else
          response_not_found(Tag.name)
        end
      end

      private

      def tag_params
        params.require(:tag).permit(:name, :group_id)
      end
    end
  end
end
