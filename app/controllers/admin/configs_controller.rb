class Admin::ConfigsController < ApplicationController

  before_action do
    @service = Service.find_by_id(params[:service_id])
    unless(@service)
      flash[:error] = 'Failed to locate requested service!'
      redirect_to admin_services_path
    end
  end

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        @configs = @service.service_config_items_dataset.order(:name).all
      end
    end
  end

  def edit
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        @config = @service.service_config_items_dataset.where(:id => params[:id]).first
        unless(@config)
          flash[:error] = 'Failed to locate requested service config item!'
          redirect_to admin_services_path
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        @config = @service.service_config_items_dataset.where(:id => params[:id]).first
        if(@config)
          @config.description = params[:description]
          @config.format_helper = params[:format_helper].present? ? params[:format_helper] : nil
          @config.enabled = params[:enabled] == '1'
          @config.save
          flash[:success] = 'Service updated!'
        else
          flash[:error] = 'Failed to locate requested configuration item!'
        end
        redirect_to admin_service_configs_path(@service)
      end
    end
  end

end
