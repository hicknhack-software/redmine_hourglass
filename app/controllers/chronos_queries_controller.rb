class ChronosQueriesController < ApplicationController
  before_filter :find_query, except: [:new, :create]
  before_filter :find_optional_project, only: [:new, :create]

  helper :queries
  include QueriesHelper

  def new
    @query = Chronos::TimeLogQuery.build_from_params params, params[:query]
    @query.user = User.current
  end

  def create
    @query = Chronos::TimeLogQuery.build_from_params params, params[:query]
    @query.user = User.current
    @query.column_names = nil if params[:default_columns]

    if @query.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to redirect_path query_id: @query.id
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    @query.attributes = params[:query]
    @query.build_from_params params
    @query.column_names = nil if params[:default_columns]

    if @query.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to redirect_path query_id: @query.id
    else
      render action: 'edit'
    end
  end

  def destroy
    @query.destroy
    redirect_to chronos_time_logs_path set_filter: 1
  end

  private
  def find_query
    @query = Chronos::TimeLogQuery.find(params[:id])
    render_403 unless @query.editable_by? User.current
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def redirect_path(options = {})
    uri = URI params[:request_referer].presence || request.referer || chronos_time_logs_path
    uri.query = URI.encode_www_form(URI.decode_www_form(uri.query || '') << options.flatten)
    uri.to_s
  end
end
