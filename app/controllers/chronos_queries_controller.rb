class ChronosQueriesController < ApplicationController
  include QueriesHelper
  include QueryConcern

  before_filter :find_query, only: [:edit, :update, :destroy]
  before_filter :find_project, :build_query, only: [:new, :create]

  helper QueriesHelper

  def new
    @query.project = @project
  end

  def create
    update_query_from_params

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
    update_query_from_params

    if @query.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to redirect_path query_id: @query.id
    else
      render action: 'edit'
    end
  end

  def destroy
    @query.destroy
    redirect_to redirect_path set_filter: 1
  end

  private
  def build_query
    @query = query_class.build_from_params params, params[:query]
    @query.user = User.current
  end

  def update_query_from_params
    @query.project = params[:query_is_for_all] ? nil : @project
    @query.column_names = nil if params[:default_columns]
    unless User.current.allowed_to?(:manage_public_queries, @query.project) || User.current.admin?
      @query.visibility = Query::VISIBILITY_PRIVATE
    end
  end

  def find_query
    @query = Query.find(params[:id])
    @project = @query.project
    render_403 unless @query.editable_by? User.current
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_project
    @project = Project.find(params[:project_id]) if params[:project_id]
    render_403 unless User.current.allowed_to?(:save_queries, @project, global: true)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def redirect_path(options = {})
    uri = URI params[:request_referer].presence || request.referer || chronos_ui_root_path
    uri.query = URI.encode_www_form(URI.decode_www_form(uri.query || '') << options.flatten)
    uri.to_s
  end
end
