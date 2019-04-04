class HourglassQueriesController < ApplicationController
  include QueriesHelper
  include QueryConcern

  before_action :find_query, only: [:edit, :update, :destroy]
  before_action :find_project, :build_query, only: [:new, :create]

  helper QueriesHelper

  def new
    @query.project = @project
    @query.build_from_params(params)
  end

  def create
    update_query_from_params
    save
  end

  def edit
  end

  def update
    update_query_from_params
    save action: :update
  end

  def destroy
    @query.destroy
    redirect_to redirect_path set_filter: 1
  end

  private
  def save(action: :create)
    if @query.save
      flash[:notice] = l(:"notice_successful_#{action}")
      redirect_to redirect_path query_id: @query.id
    else
      render action: action == :create ? 'new' : 'edit'
    end
  end

  def build_query
    @query = query_class.new
    @query.user = User.current
  end

  def update_query_from_params
    @query.project = params[:query_is_for_all] ? nil : @project
    @query.build_from_params(params)
    @query.column_names = nil if params[:default_columns]
    @query.sort_criteria = (params[:query] && params[:query][:sort_criteria]) || @query.sort_criteria
    @query.name = params[:query] && params[:query][:name]
    if User.current.allowed_to?(:manage_public_queries, @query.project) || User.current.admin?
      @query.visibility = (params[:query] && params[:query][:visibility]) || Query::VISIBILITY_PRIVATE
      @query.role_ids = params[:query] && params[:query][:role_ids]
    else
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
    @project = Project.visible.find(params[:project_id]) if params[:project_id]
    render_403 unless User.current.allowed_to?(:save_queries, @project, global: true)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def redirect_path(options = {})
    uri = URI params[:request_referer].presence || request.referer || hourglass_ui_root_path
    uri.query = URI.encode_www_form(URI.decode_www_form(uri.query || '') << options.flatten)
    uri.to_s
  end
end
