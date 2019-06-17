# frozen_string_literal: true

module Api
  module V1
    class StocksController < ApplicationController
      before_action :authenticate_api_v1_user!
      def create
        job = Job.find_by(id: stock_params[:job_id])
        if job.nil?
          response_not_found(Job.name)
          return
        end

        is_not_member = job.group.members.pluck(:user_id).index(current_api_v1_user.id).nil?
        is_private_job = !job.is_public?

        if is_not_member && is_private_job
          response_not_acceptable(Member.name)
          return
        end

        stock = current_api_v1_user.stocks.build(stock_params)
        if stock.valid?
          stock.save
          response_created(stock)
        else
          response_bad_request(stock)
        end
      end

      def index
        stock_jobs = current_api_v1_user.stock_jobs
        if stock_jobs.present?
          response_success(stock_jobs)
        else
          response_not_found(Stock.name)
        end
      end

      def destroy
        stock = Stock.find_by(id: params[:id])

        if stock.nil?
          response_not_found(Stock.name)
          return
        end

        if current_api_v1_user.stocks.pluck(:id).index(stock.id).nil?
          response_not_acceptable(Member.name)
          return
        end

        if stock.destroy
          response_success(stock)
        else
          response_bad_request(stock)
        end
      end

      private

      def stock_params
        params.require(:stock).permit(:job_id)
      end
    end
  end
end
