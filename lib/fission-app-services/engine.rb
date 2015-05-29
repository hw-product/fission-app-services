module FissionApp
  module Services
    class Engine < ::Rails::Engine

      config.to_prepare do |config|

        Jackal.service_info.each do |service_name, info|
          service = Fission::Data::Models::Service.find_or_create(
            :name => service_name
          )
          service.description = info.description
          service.category = info.category
          service.save
        end

        product = Fission::Data::Models::Product.find_or_create(
          :name => 'Services'
        )
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
        if(product.internal_name == 'fission')
          Smash.new(
            'Admin' => Smash.new(
              'Services' => Rails.application.routes.url_helpers.admin_services_path,
              'Service Groups' => Rails.application.routes.url_helpers.admin_service_groups_path
            )
          )
        else
          Smash.new
        end
      end

      # @return [Hash] account navigation
      def fission_account_navigation(product, current_user)
        if(product.internal_name == 'services')
          Smash.new('Custom Services' => Rails.application.routes.url_helpers.custom_services_path)
        else
          Smash.new
        end
      end

    end
  end
end
