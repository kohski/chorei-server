# frozen_string_literal: true

module Api
  module V1
    class TagsController < ApplicationController
      def create
        tag = Tag.create(tag_params)
        if tag.valid?
          response_created(tag)
        else
          response_bad_request(tag)
        end
      end

      def index
        tags = Tag.all
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

        if tag.destroy
          response_success(tag)
        else
          response_bad_request(tag)
        end
      end

      private

      def tag_params
        params.require(:tag).permit(:name)
      end
    end
  end
end