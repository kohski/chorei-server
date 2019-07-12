# frozen_string_literal: true

module Api
  module V1
    class SchedulesController < ApplicationController
      before_action :authenticate_api_v1_user!
      before_action :set_job, only: %i[create index]

      def create
        if @job.nil?
          response_not_found(Job.name)
          return
        end
        unless Member.in_member?(@job.group, current_api_v1_user)
          response_not_acceptable(Member.name)
          return
        end
        schedule = @job.schedules.build(schedule_params)
        if schedule.valid?
          schedule.save
          response_created(schedule)
        else
          response_bad_request(schedule)
        end
      end

      def index
        if @job.nil?
          response_not_found(Job.name)
          return
        end
        unless Member.in_member?(@job.group, current_api_v1_user)
          response_not_acceptable(Member.name)
          return
        end
        schedules = @job.schedules
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

        unless Member.in_member?(schedule.job.group, current_api_v1_user)
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
        unless Member.in_member?(schedule.job.group, current_api_v1_user)
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

        unless Member.in_member?(schedule.job.group, current_api_v1_user)
          response_not_acceptable(Member.name)
          return
        end
        if schedule.destroy
          response_success(schedule)
        else
          response_bad_request(schedule)
        end
      end

      def frequency_master
        response_success(frequencies: Schedule.frequencies)
      end

      def index_assigned_schedules
        assigned_jobs = Job.assigned_jobs_with_user(current_api_v1_user)
        assigend_schedules = Schedule.assigned_schedules(assigned_jobs)
        assigend_schedules_with_job = assigend_schedules.map { |sch| sch.attributes.merge(job_entity: assigned_jobs.find { |job| job.id == sch.job_id }.attributes) }
        if assigend_schedules_with_job.present?
          response_success(assigend_schedules_with_job)
        else
          response_not_found(Schedule.name)
        end
      end

      private

      def schedule_params
        params.require(:schedule).permit(:frequency, :repeat_time, :start_at, :end_at, :is_done)
      end

      def set_job
        @job = Job.find_by(id: params[:job_id])
      end
    end
  end
end
