# frozen_string_literal: true

module Api
  module V1
    class StepsController < ApplicationController
      before_action :authenticate_api_v1_user!
      def create
        job = Job.find_by(id: params[:job_id])

        if job.nil?
          response_not_found(Job.name)
          return
        end

        if job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Member.name)
          return
        end

        step = job.steps.build(step_params)

        if step.valid?
          step.save
          response_created(step)
        else
          response_bad_request(step)
        end
      end

      def index
        job = Job.find_by(id: params[:job_id])

        if job.nil?
          response_not_found(Job.name)
          return
        end

        if job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Member.name)
          return
        end

        steps = job.steps

        if steps.present?
          response_success(steps)
        else
          response_not_found(steps)
        end
      end

      def update
        step = Step.find_by(id: params[:id])
        if step.nil?
          response_not_found(Step.name)
          return
        end

        if step.job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Member.name)
          return
        end

        if step.update(step_params)
          response_success(step)
        else
          response_bad_request(step)
        end
      end

      def show
        step = Step.find_by(id: params[:id])
        if step.nil?
          response_not_found(Step.name)
          return
        end

        if step.job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Member.name)
          return
        end
        response_success(step)
      end

      def destroy
        step = Step.find_by(id: params[:id])
        if step.nil?
          response_not_found(Step.name)
          return
        end

        if step.job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Member.name)
          return
        end

        if step.destroy
          response_success(step)
        else
          response_bad_request(step)
        end
      end

      private

      def step_params
        params.require(:step).permit(:memo, :image, :order, :is_done)
      end
    end
  end
end
