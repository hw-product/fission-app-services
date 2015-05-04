module FissionApp
  module Services
    class Engine < ::Rails::Engine

      config.to_prepare do |config|

        Jackal.service_info.each do |service, info|
          service = Fission::Data::Models::Service.find_or_create(
            :name => service
          )
          unless(service.description == info.description)
            service.description = info.description
            service.save
          end
        end

        product = Fission::Data::Models::Product.find_by_internal_name('services')
        unless(product)
          product = Fission::Data::Models::Product.create(
            :name => 'Services'
          )
        end
        feature = Fission::Data::Models::ProductFeature.find_by_name('services_custom_services')
        unless(feature)
          feature = Fission::Data::Models::ProductFeature.create(
            :name => 'services_custom_services',
            :product_id => product.id
          )
        end
        unless(feature.permissions_dataset.where(:name => 'services_custom_services').count > 0)
          args = {:name => 'services_custom_services', :pattern => '/custom_services.*'}
          permission = Fission::Data::Models::Permission.where(args).first
          unless(permission)
            permission = Fission::Data::Models::Permission.create(args)
          end
          unless(feature.permissions.include?(permission))
            feature.add_permission(permission)
          end
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
      def fission_navigation(*_)
        Smash.new(
          'Admin' => Smash.new(
            'Services' => Rails.application.routes.url_helpers.admin_services_path,
            'Service Groups' => Rails.application.routes.url_helpers.admin_service_groups_path
          ),
          'Services' => Smash.new(
            'Custom Services' => Rails.application.routes.url_helpers.custom_services_path
          )
        )
      end

    end
  end
end
