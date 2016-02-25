require 'fission-app'

# Default configuration pack event hook
# TODO: This is hard coded to request stack information. Should be plan dependent
FissionApp.subscribe(/^before_(render|redirect)\..+?\.routes\.fission_app/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  account = event.payload[:account]
  default_config = account.account_configs_dataset.where(:name => 'default').first
  unless(default_config)
    default_config = Fission::Data::Models::AccountConfig.create(
      :name => 'default',
      :account_id => account.id
    )
    Fission::Data::Models::Notification.create(
      :subject => 'Default configuration created!',
      :message => "A default configuration pack has been created for you. [Click here to get started!](#{Rails.application.routes.url_helpers.edit_config_path(default_config, :auto_add => [:stacks])})"
    ).add_account(account)
  end
end
