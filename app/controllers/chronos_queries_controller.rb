class ChronosQueriesController < ApplicationController
  include QueriesHelper
  include QueryConcern

  before_filter :find_query, except: [:new, :create]
  before_filter :build_query, only: [:new, :create]

  helper QueriesHelper

  def new
  end

  def create
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
    redirect_to redirect_path set_filter: 1
  end

  private
  def build_query
    @query = query_class.build_from_params params, params[:query]
    @query.user = User.current
  end

  def find_query
    @query = Query.find(params[:id])
    render_403 unless @query.editable_by? User.current
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def redirect_path(options = {})
    uri = URI params[:request_referer].presence || request.referer || chronos_root_path
    uri.query = URI.encode_www_form(URI.decode_www_form(uri.query || '') << options.flatten)
    uri.to_s
  end
end
