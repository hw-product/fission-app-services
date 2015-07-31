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
        @products = Product.order(:name).all
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
        group.price = params[:price].to_i
        group.remove_all_product_features
        ProductFeature.where(:id => params[:product_features]).all.each do |pf|
          unless(group.product_features.include?(pf))
            group.add_product_feature(pf)
          end
        end
        save_filters(group)
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
          @products = Product.order(:name).all
          @match_rules = PayloadMatchRule.order(:name).all
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
          @service_group.price = params[:price].to_i
          @service_group.remove_all_product_features
          ProductFeature.where(:id => params[:product_features]).all.each do |pf|
            unless(@service_group.product_features.include?(pf))
              @service_group.add_product_feature(pf)
            end
          end
          save_filters(@service_group)
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
      format.js do
        javascript_redirect_to admin_service_groups_path
      end
      format.html do
        redirect_to admin_service_groups_path
      end
    end
  end

  # route filters

  def add_filter_rule
    respond_to do |format|
      format.js do
        @rule = PayloadMatchRule.find_by_id(params[:rule])
        @identifier = params[:identifier]
      end
      format.html do
        flash[:error] = 'Unsupported request!'
        redirect_to dashboard_path
      end
    end
  end

  def apply_filter_rule
    respond_to do |format|
      format.js do
        @rule = PayloadMatchRule.find_by_id(params[:rule_id])
        @identifier = params[:identifier]
        @value = params[:value]
      end
      format.html do
        flash[:error] = 'Unsupported request!'
        redirect_to dashboard_path
      end
    end
  end

  def remove_filter_rule
    respond_to do |format|
      format.js do
        @rule_ident = params[:rule_ident]
      end
      format.html do
        flash[:error] = 'Unsupported request!'
        redirect_to dashboard_path
      end
    end
  end

  def add_filter
    respond_to do |format|
      format.js do
        @match_rules = PayloadMatchRule.order(:name).all
      end
      format.html do
        flash[:error] = 'Unsupported request!'
        redirect_to dashboard_path
      end
    end
  end

  def remove_filter
    respond_to do |format|
      format.js do
        @ident = params[:ident]
      end
      format.html do
        flash[:error] = 'Unsupported request!'
        redirect_to dashboard_path
      end
    end
  end

  def save_filters(service_group)
    sg_filter_ids = params.fetch('filters', {}).map do |ident, filter|
      sg_filter = ServiceGroupPayloadFilter.find_or_create(
        :name => filter[:name],
        :description => filter[:description],
        :service_group_id => service_group.id
      )
      if(filter)
        current_matchers = sg_filter.payload_matchers.dup
        filter.fetch(:rule_id, {}).each do |r_idx, r_pair|
          matcher = PayloadMatcher.find_or_create(
            :payload_match_rule_id => r_pair.keys.first,
            :account_id => @account.id,
            :value => r_pair.values.first
          )
          if(current_matchers.include?(matcher))
            current_matchers.delete(matcher)
          else
            sg_filter.add_payload_matcher(matcher)
          end
        end
        current_matchers.each do |stale_matcher|
          sg_filter.remove_payload_matcher(stale_matcher)
        end
      end
      sg_filter.id
    end
    service_group.service_group_payload_filters.find_all do |filter|
      unless(sg_filter_ids.include?(filter.id))
        filter.destroy
      end
    end
  end


end
