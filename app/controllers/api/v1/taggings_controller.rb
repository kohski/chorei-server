# frozen_string_literal: true

module Api
  module V1
    class TaggingsController < ApplicationController
      before_action :authenticate_api_v1_user!
      def create
        job = Job.find_by(id: tagging_params[:job_id])
        if job.nil?
          response_not_found(Job.name)
          return
        end
        tag = Tag.find_by(id: tagging_params[:tag_id])
        if tag.nil?
          response_not_found(Tag.name)
          return
        end

        unless Member.in_member?(job.group, current_api_v1_user)
          response_forbidden(Member.name)
          return
        end

        tagging = job.taggings.build(tagging_params)
        if tagging.valid?
          tagging.save
          response_created(tagging)
        else
          response_bad_request(tagging)
        end
      end

      def destroy
        tagging = Tagging.find_by(id: params[:id])

        if tagging.nil?
          response_not_found(Tagging.name)
          return
        end

        unless Member.in_member?(tagging.job.group, current_api_v1_user)
          response_forbidden(Member.name)
          return
        end

        response_success(tagging) if tagging.destroy
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
        taggings = job.taggings
        if taggings.present?
          response_success(taggings)
        else
          response_not_found(Tagging.name)
        end
      end

      def index_with_group_id
        group = Group.find_by(id: params[:group_id])
        if group.nil?
          response_not_found(Group.name)
          return
        end
        unless Member.in_member?(group, current_api_v1_user)
          response_forbidden(User.name)
          return
        end
        job_ids = group.jobs.pluck(:id)
        taggings = Tagging.where(job_id: job_ids)
        if taggings.present?
          response_success(taggings)
        else
          response_not_found(Tagging.name)
        end
      end

      private

      def tagging_params
        params.require(:tagging).permit(:job_id, :tag_id)
      end
    end
  end
end
