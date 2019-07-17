# frozen_string_literal: true

module Api
  module V1
    class StepsController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :set_job, only: %i[create index]
      before_action :set_step, only: %i[update show destroy]

      def create
        if @job.nil?
          response_not_found(Job.name)
          return
        end

        unless Member.in_member?(@job.group, current_api_v1_user)
          response_forbidden(Member.name)
          return
        end

        step = @job.steps.build(step_params)

        if step.valid?
          step.save
          response_created(step)
        else
          response_bad_request(step)
        end
      end

      def index
        if @job.nil?
          response_not_found(Job.name)
          return
        end

        unless Member.in_member?(@job.group, current_api_v1_user)
          response_forbidden(Member.name)
          return
        end

        steps = @job.steps

        if steps.present?
          response_success(steps)
        else
          response_not_found(steps)
        end
      end

      def update
        if @step.nil?
          response_not_found(Step.name)
          return
        end

        unless Member.in_member?(@step.job.group, current_api_v1_user)
          response_forbidden(Member.name)
          return
        end

        response_success(@step) if @step.update(step_params)
      end

      def show
        if @step.nil?
          response_not_found(Step.name)
          return
        end

        unless Member.in_member?(@step.job.group, current_api_v1_user)
          response_forbidden(Member.name)
          return
        end
        response_success(@step)
      end

      def destroy
        if @step.nil?
          response_not_found(Step.name)
          return
        end

        unless Member.in_member?(@step.job.group, current_api_v1_user)
          response_forbidden(Member.name)
          return
        end
        response_success(@step) if @step.destroy
      end

      private

      def step_params
        params.require(:step).permit(:memo, :image, :order, :is_done)
      end

      def set_job
        @job = Job.find_by(id: params[:job_id])
      end

      def set_step
        @step = Step.find_by(id: params[:id])
      end
    end
  end
end
