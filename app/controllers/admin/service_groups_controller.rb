class Admin::ServiceGroupsController < ApplicationController

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        @service_groups = ServiceGroup.order(:name).all
      end
    end
  end

  def new
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        @services = Service.order(:name).all
        @product_features = ProductFeature.order(:name).all
      end
    end
  end

  def create
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        group = ServiceGroup.create(
          :name => params[:name],
          :description => params[:description]
        )
        services = Service.where(:id => params[:services]).all
        params[:services].each_with_index do |srv_id, idx|
          srv = services.detect{|s| s.id == srv_id.to_i}
          group.add_service(
            :position => idx,
            :service => srv
          )
        end
        group.remove_all_product_features
        ProductFeature.where(:id => params[:product_features]).all.each do |pf|
          unless(group.product_features.include?(pf))
            group.add_product_feature(pf)
          end
        end

        flash[:success] = 'New group created!'
        redirect_to admin_service_groups_path
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
        @service_group = ServiceGroup.find_by_id(params[:id])
        if(@service_group)
          @services = Service.order(:name).all - @service_group.services
          @product_features = ProductFeature.order(:name).all
        else
          flash[:error] = 'Failed to locate requested group'
          redirect_to admin_service_groups_path
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
        @service_group = ServiceGroup.find_by_id(params[:id])
        if(@service_group)
          @service_group.remove_all_services
          services = Service.where(:id => params[:services]).all
          params[:services].each_with_index do |srv_id, idx|
            srv = services.detect{|s| s.id == srv_id.to_i}
            @service_group.add_service(
              :position => idx,
              :service => srv
            )
          end
          @service_group.remove_all_product_features
          ProductFeature.where(:id => params[:product_features]).all.each do |pf|
            unless(@service_group.product_features.include?(pf))
              @service_group.add_product_feature(pf)
            end
          end

          flash[:success] = 'Group updated!'
          redirect_to admin_service_groups_path
        else
          flash[:error] = 'Failed to locate requested group'
          redirect_to admin_service_groups_path
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        group = ServiceGroup.find_by_id(params[:id])
        if(group)
          if(group.destroy)
            flash[:success] = 'Group successfully destroyed!'
          else
            flash[:error] = 'Failed to destroy group!'
          end
        else
          flash[:error] = 'Failed to locate requested group!'
        end
        redirect_to admin_service_groups_path
      end
    end
  end

end
