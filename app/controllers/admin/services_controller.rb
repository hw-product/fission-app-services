class Admin::ServicesController < ApplicationController

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        @services = Service.order(:name).all
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
        @service = Service.find_by_id(params[:id])
        if(@service)
          @products = Product.order(:name).eager_graph(:product_features).all.find_all do |prod|
            !prod.product_features.empty?
          end
        else
          flash[:error] = 'Failed to locate requested service!'
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
        @service = Service.find_by_id(params[:id])
        @service.remove_all_product_features
        ProductFeature.where(:id => params[:product_features]).all.each do |pf|
          unless(@service.product_features.include?(pf))
            @service.add_product_feature(pf)
          end
        end
        price_value = params[:price].to_i * 100
        unless(@service.cost == params[:price])
          @service.price = params[:price]
        end
        flash[:success] = 'Service updated!'
        redirect_to admin_services_path
      end
    end
  end

end
