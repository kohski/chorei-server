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
          response_forbidden(Member.name)
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
          response_forbidden(Member.name)
          return
        end
        schedules = @job.schedules
        response_success(schedules) if schedules.present?
      end

      def show
        schedule = Schedule.find_by(id: params[:id])

        if schedule.nil?
          response_not_found(Schedule.name)
          return
        end

        unless Member.in_member?(schedule.job.group, current_api_v1_user)
          response_forbidden(Member.name)
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
          response_forbidden(Member.name)
          return
        end
        response_success(schedule) if schedule.update(schedule_params)
      end

      def destroy
        schedule = Schedule.find_by(id: params[:id])

        if schedule.nil?
          response_not_found(Schedule.name)
          return
        end

        unless Member.in_member?(schedule.job.group, current_api_v1_user)
          response_forbidden(Member.name)
          return
        end
        response_success(schedule) if schedule.destroy
      end

      def index_assigned_schedules
        assigned_jobs = Job.assigned_jobs_with_user(current_api_v1_user)
        assigned_schedules = Schedule.assigned_schedules(assigned_jobs)
        assigned_schedules_with_job = Schedule.assigned_schedules_with_job(assigned_schedules, assigned_jobs)
        if assigned_schedules_with_job.present?
          response_success(assigned_schedules_with_job)
        else
          response_not_found(Schedule.name)
        end
      end

      def index_group_schedules
        group = Group.find_by(id: params[:group_id])
        if group.nil?
          response_not_found(Group.name)
          return
        end
        jobs = group.jobs
        assigned_schedules = Schedule.assigned_schedules(jobs)
        assigned_schedules_with_job = Schedule.assigned_schedules_with_job(assigned_schedules, jobs)
        if assigned_schedules_with_job.present?
          response_success(assigned_schedules_with_job)
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
