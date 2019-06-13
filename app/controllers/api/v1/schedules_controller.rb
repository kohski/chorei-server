# frozen_string_literal: true

module Api
  module V1
    class SchedulesController < ApplicationController
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
        schedule = job.schedules.build(schedule_params)
        if schedule.valid?
          schedule.save
          response_created(schedule)
        else
          response_bad_request(schedule)
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
        schedules = job.schedules
        if schedules.present?
          response_success(schedules)
        else
          response_not_found(schedules)
        end
      end

      def show
        schedule = Schedule.find_by(id: params[:id])

        if schedule.nil?
          response_not_found(Schedule.name)
          return
        end

        if schedule.job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Member.name)
          return
        end

        response_success(schedule)
      end

      def update
        schedule = Schedule.find_by(id: params[:id])
        if schedule.nil?
          response_not_found(Schedule.name)
          return
        end
        if schedule.job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Member.name)
          return
        end
        if schedule.update(schedule_params)
          response_success(schedule)
        else
          response_bad_request(schedule)
        end
      end

      def destroy
        schedule = Schedule.find_by(id: params[:id])

        if schedule.nil?
          response_not_found(Schedule.name)
          return
        end

        if schedule.job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
          response_not_acceptable(Member.name)
          return
        end
        if schedule.destroy
          response_success(schedule)
        else
          response_bad_request(schedule)
        end
      end

      private

      def schedule_params
        params.require(:schedule).permit(:frequency, :repeat_time, :start_at, :end_at, :is_done)
      end
    end
  end
end
