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
        javascript_redirect_to dashboard_url
      end
      format.html do
        @services = @account.product_features.map(&:services).flatten.uniq.sort_by(&:name)
      end
    end
  end

  def create
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_url
      end
      format.html do
        @services = @account.product_features.map(&:services).flatten.uniq
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
        javascript_redirect_to dashboard_url
      end
      format.html do
        @config = @account.account_configs_dataset.where(:id => params[:id]).first
        unless(@config)
          flash[:error] = 'Failed to locate requested configuration pack!'
          redirect_to configs_path
        else
          @services = @account.product_features.map(&:services).flatten.uniq.sort_by(&:name)
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.js do
        flash[:error] = 'Unsupported request!'
        javascript_redirect_to dashboard_url
      end
      format.html do
        account_config = @account.account_configs_dataset.where(:id => params[:id]).first
        if(account_config)
          @services = @account.product_features.map(&:services).flatten.uniq
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

  protected

  def assign_config(services)
    config = Smash.new
    services.each do |srv|
      srv.service_config_items.each do |item|
        if(params[:account_config] && params[:account_config][srv.id.to_s] && !params[:account_config][srv.id.to_s][item.id.to_s].blank?)
          val = params[:account_config][srv.id.to_s][item.id.to_s]
          case item.type
          when 'hash'
            val = MultiJson.load(val)
            next if val.empty?
          when 'boolean'
            val = val == '1'
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

end
