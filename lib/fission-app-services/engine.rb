module FissionApp
  module Services
    class Engine < ::Rails::Engine

      config.to_prepare do |config|

        require 'fission-app-services/subscriptions/default_config'

        Jackal.service_info.each do |service_name, info|
          service = Fission::Data::Models::Service.find_or_create(
            :name => service_name
          )
          service.description = info.description
          service.category = info.category.to_s
          service.save

          info.configuration.each do |config|
            item = Fission::Data::Models::ServiceConfigItem.where(
              :service_id => service.id,
              :name => config.name.to_s
            ).first
            # NOTE: We only set enabled when first adding service
            # config item to the system. Otherwise we may end up
            # enabling a config item that was explicitly disabled by a
            # site administrator.
            unless(item)
              item = Fission::Data::Models::ServiceConfigItem.find_or_create(
                :service_id => service.id,
                :name => config.name.to_s,
                :enabled => config.public
              )
            end
            item.description = config.description
            item.type = config.type.to_s
            item.save
          end
        end

        FissionApp.init_product(:fission)
        product = FissionApp.init_product(:services)
        feature = Fission::Data::Models::ProductFeature.find_or_create(
          :name => 'Custom Services',
          :product_id => product.id
        )
        permission = Fission::Data::Models::Permission.find_or_create(
          :name => 'Custom services access',
          :pattern => '/custom_services.*'
        )
        unless(feature.permissions.include?(permission))
          feature.add_permission(permission)
        end
        feature = Fission::Data::Models::ProductFeature.find_or_create(
          :name => 'Configuration Pack Editor',
          :product_id => product.id
        )
        permission = Fission::Data::Models::Permission.find_or_create(
          :name => 'Configuration packs editor access',
          :pattern => '/configs.*'
        )
        unless(feature.permissions.include?(permission))
          feature.add_permission(permission)
        end
      end

      # @return [Array<Fission::Data::Models::Product>]
      def fission_product
        [
          Fission::Data::Models::Product.find_by_internal_name('fission'),
          Fission::Data::Models::Product.find_by_internal_name('services')
        ]
      end

      # @return [Hash] navigation
      def fission_navigation(product, current_user)
        Smash.new(
          'Admin' => Smash.new(
            'Services' => Rails.application.routes.url_helpers.admin_services_path,
            'Service Groups' => Rails.application.routes.url_helpers.admin_service_groups_path
          )
        )
      end

      # @return [Hash] account navigation
      def fission_account_navigation(product, current_user)
        Smash.new(
          'Config' => Rails.application.routes.url_helpers.configs_path,
          'Custom Services' => Rails.application.routes.url_helpers.custom_services_path
        )
      end

    end
  end
end
