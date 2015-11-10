module Chronos
  class TimeTrackerController < ApplicationController
    accept_api_auth :index, :show, :start, :update, :stop, :destroy

    def index
      render json: {test: true}
    end

    def show
    end

    def start
      time_tracker = TimeTracker.start
      if time_tracker.persisted?
        render json: time_tracker
      else
        render json: {errors: time_tracker.errors.full_messages}
      end
    end

    def update
    end

    def stop
    end

    def destroy
    end

  end
end