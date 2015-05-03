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
      end

      # @return [Array<Fission::Data::Models::Product>]
      def fission_product
        [Fission::Data::Models::Product.find_by_internal_name('fission')]
      end

      # @return [Hash] navigation
      def fission_navigation(*_)
        Smash.new(
          'Admin' => Smash.new(
            'Services' => Rails.application.routes.url_helpers.admin_services_path
          )
        )
      end

    end
  end
end
