require 'fission-app'

# Default configuration pack event hook
FissionApp.subscribe(/^before_(render|redirect)\..+?\.routes\.fission_app/) do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  account = event.payload[:account]
  default_config = account.account_configs_dataset.where(:name => 'default').first
  unless(default_config)
    Fission::Data::Models::AccountConfig.create(
      :name => 'default',
      :account_id => account.id
    )
    Fission::Data::Models::Notification.create(
      :subject => 'Default configuration created!',
      :message => 'Go configure your services!'
    ).add_account(account)
  end
end
