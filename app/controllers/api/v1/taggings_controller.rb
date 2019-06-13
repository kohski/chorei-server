# frozen_string_literal: true

module Api
  module V1
    class TaggingsController < ApplicationController
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

        if tagging.destroy
          response_success(tagging)
        else
          response_bad_request(tagging)
        end
      end

      private

      def tagging_params
        params.require(:tagging).permit(:job_id, :tag_id)
      end
    end
  end
end
