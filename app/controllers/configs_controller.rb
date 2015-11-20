class ConfigsController < ApplicationController

  def index
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_path
      end
      format.html do
        @configs = @account.account_configs_dataset.order(:name)
      end
    end
  end

  def new
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to configs_path
      end
      format.html do
        populate_services!
      end
    end
  end

  def create
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to configs_path
      end
      format.html do
        populate_services!
        config = assign_config(@services)
        AccountConfig.create(
          :name => Bogo::Utility.snake(params[:name]).tr(' ', '_'),
          :description => params[:description],
          :data => config,
          :account_id => @account.id
        )
        flash[:success] = 'New configuration pack created!'
        redirect_to configs_path
      end
    end
  end

  def edit
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to configs_path
      end
      format.html do
        @config = @account.account_configs_dataset.where(:id => params[:id]).first
        unless(@config)
          flash[:error] = 'Failed to locate requested configuration pack!'
          redirect_to configs_path
        else
          populate_services!
          @defined_services = @services.find_all do |srv|
            @config.data[srv.name]
          end
          @undefined_services = @services - @defined_services
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to configs_path
      end
      format.html do
        account_config = @account.account_configs_dataset.where(:id => params[:id]).first
        if(account_config)
          populate_services!
          config = assign_config(@services)
          account_config.data = config
          account_config.description = params[:description]
          account_config.save
          flash[:success] = 'Configuration updated!'
          redirect_to configs_path
        else
          flash[:error] = 'Failed to located requested configuration pack!'
          redirect_to configs_path
        end
      end
    end
  end

  def destroy
    respond_to do |format|
      account_config = @account.account_configs_dataset.where(:id => params[:id]).first
      if(account_config)
        account_config.destroy
        flash[:success] = 'Configuration pack destroyed!'
      else
        flash[:error] = 'Failed to located requested configuration pack!'
      end
      format.js do
        javascript_redirect_to configs_path
      end
      format.html do
        redirect_to configs_path
      end
    end
  end

  def edit_service
    respond_to do |format|
      format.js do
        populate_services!
        @config = assign_config(@services, params[:data])
        @service = @services.detect{|s| s.name == params[:service]}
      end
      format.html do
        flash[:error] = 'Unsupported request!'
        redirect_to configs_path
      end
    end
  end

  def preview_service
    respond_to do |format|
      format.js do
        populate_services!
        @config = assign_config(@services, params[:data])
        @service = @services.detect{|s| s.name == params[:service]}
      end
      format.html do
        flash[:error] = 'Unsupported request!'
        redirect_to configs_path
      end
    end
  end

  def apply_service
    respond_to do |format|
      format.js do
        populate_services!
        @config = assign_config(@services, params[:data])
        @service = @services.detect{|s| s.name == params[:service]}
        if(@service && !@config.has_key?(@service.name))
          @config[@service.name] = Smash.new
        end
        @defined_services = @services.find_all do |srv|
          @config.keys.include?(srv.name)
        end
      end
      format.html do
        flash[:error] = 'Unsupported request!'
        redirect_to configs_path
      end
    end
  end

  def list_services
    respond_to do |format|
      format.js do
        populate_services!
        @config = assign_config(@services, params[:data])
        @available_services = @services.find_all do |srv|
          !@config.keys.include?(srv.name)
        end
      end
      format.html do
        flash[:error] = 'Unsupported request!'
        redirect_to configs_path
      end
    end
  end

  protected

  def assign_config(services, p_items=nil)
    p_items = params unless p_items
    config = Smash.new
    services.each do |srv|
      srv.service_config_items.each do |item|
        if(p_items[:account_config] && p_items[:account_config][srv.id.to_s] && !p_items[:account_config][srv.id.to_s][item.id.to_s].blank?)
          val = p_items[:account_config][srv.id.to_s][item.id.to_s]
          case item.type
          when 'hash'
            unless(val.is_a?(Hash))
              val = MultiJson.load(val)
            end
            next if val.empty?
          when 'boolean'
            val = val == 'true'
            next unless val
          when 'number'
            val = val.to_f
          end
          config.set(*item.name.split('__').unshift(srv.name), val)
        end
      end
    end
    config
  end

  def populate_services!
    @services = @account.product_features.map(&:services).flatten.uniq.sort_by(&:name).find_all do |srv|
      srv.service_config_items_dataset.count > 0
    end
  end

end
