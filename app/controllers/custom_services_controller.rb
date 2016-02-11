class CustomServicesController < ApplicationController

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        @services = @account.custom_services_dataset.order(:name).all
      end
    end
  end

  def new
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html
    end
  end

  def create
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        srv = CustomService.create(
          :name => Bogo::Utility.snake(params[:name]).tr(' ', '_'),
          :enabled => !!params[:enabled],
          :endpoint => params[:endpoint],
          :account_id => @account.id
        )
        notify!(:create, :custom_service => srv)
        flash[:success] = 'New custom service created!'
        redirect_to custom_services_path
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
        @service = CustomService.find_by_id(params[:id])
        unless(@service)
          flash[:error] = 'Failed to locate requested custom service!'
          redirect_to custom_services_path
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
        service = CustomService.find_by_id(params[:id])
        if(service)
          service.enabled = !!params[:enabled]
          service.endpoint = params[:endpoint]
          service.save
          notify!(:update, :custom_service => service)
          flash[:success] = 'New custom service created!'
          redirect_to custom_services_path
        else
          flash[:error] = 'Failed to locate requested custom service!'
          redirect_to custom_services_path
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      service = CustomService.find_by_id(params[:id])
      if(service)
        if(service.destroy)
          notify!(:destroy, :custom_service => service)
          flash[:success] = 'Custom service successfully destroyed!'
        else
          flash[:error] = 'Failed to destroy custom service!'
        end
      else
        flash[:error] = 'Failed to locate requested custom service!'
      end
      format.js do
        javascript_redirect_to custom_services_path
      end
      format.html do
        redirect_to custom_services_path
      end
    end
  end

end
