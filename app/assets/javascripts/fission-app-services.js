var fission_services = {data: {}};

fission_services.gather_configs = function(){
  current_data = {};
  $('.config-item-data textarea').each(function(){
    current_data[$(this).attr('name')] = $(this).val();
  });
  return current_data;
}

fission_services.gather_modified = function(){
  current_modified = []
  $('.config-item-data.modified').each(function(){
    current_modified.push($(this).parents('.config-item').attr('data-service-name'));
  });
  return current_modified;
}

fission_services.apply_configs = function(srv_name){
  $.post(fission_services.data['apply_service_configs_path'], {
    data: fission_services.gather_configs(),
    service: srv_name,
    modified_services: fission_services.gather_modified(),
    success: function(){
      if(srv_name){
        setTimeout(function(){
          $('#service-config-' + srv_name).trigger('click');
        }, 1500);
      }
    }
  });
}

fission_services.delete_service_config = function(elm){
  root = elm.parents('.config-item');
  root.find('.config-item-data').remove();
  sparkle_ui.display.highlight(root.attr('id'), 'danger');
  setTimeout(function(){
    root.toggle('fade');
    fission_services.apply_configs();
    window_rails.loading.close();
  }, 1000);
}

fission_services.config_form_setup = function(){
  $('.edit-control').click(function(){
    current_data = {};
    $(this).parents('.config-item').find('.config-item-data textarea').each(function(){
      current_data[$(this).attr('name')] = $(this).val();
    });
    $.post(fission.data['edit_service_configs_path'], {
      config: fission_services.data['config_id'],
      service: $(this).parents('.config-item').attr('data-service-name'),
      data: current_data
    });
    return false;
  });

  $('#service-config-adder').click(function(){
    $.post(fission_services.data['list_services_configs_path'], {
      data: fission_services.gather_configs()
    });
    return false;
  });

  $('.config-item-delete').click(function(){
    window_rails.confirm.open({
      content: 'Delete service configuration item',
      callback: 'fission_services.delete_service_config',
      title: 'Service Configuration Removal',
      element: $(this)
    });
    return false;
  });

  $('.service-config-panel.config-item').click(function(){
    current_data = {};
    $(this).find('.config-item-data textarea').each(function(){
      current_data[$(this).attr('name')] = $(this).val();
    });
    $.post(fission_services.data['edit_service_configs_path'], {
      config: fission_services.data['config_id'],
      service: $(this).attr('data-service-name'),
      data: current_data
    });
    return false;
  });

  if(fission_services.data['auto_add'] && fission_services.data['auto_add'].length > 0 && !fission_services.paused_adder){
    fission_services.paused_adder = true;
    setTimeout(function(){ fission_services.paused_adder = false; }, 500);
    initial = fission_services.data['auto_add'].shift();
    fission_services.apply_configs(initial);
  }
}
