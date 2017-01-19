function toggleMachineService(machineId, serviceId, environmentCode) {
  // alert('Machine Service Toggled: ' + machine_id + ', ' + service_id + ', ' + environmentCode);
  params = [
    { name: "machine_id", value: machineId},
    { name: "service_id", value: serviceId},
    { name: "environment_code", value: environmentCode}
  ]
  
  $.ajax({
      beforeSend: function(xhr) {
        var csrf = $('meta[name="csrf-token"]').attr('content');
        xhr.setRequestHeader('X-CSRF-Token', csrf);
      },
      url: '/v1/machines/toggle_service',
      type: 'post',
      dataType: 'text',
      data: $.param(params),
      success: function(data) {
        result = JSON.parse(data)
        divId = "#div_" + machineId + "_" + serviceId + "_" + environmentCode;
        if (result['service_on']) {
          $(divId).html('<div style="width: 80px; height: 14px; background: green; border-radius: 6px"></div>');
        } else {
          $(divId).html("");
        }
      },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          alert('Error toggling service: ' + textStatus);
        }
  });
  
}

function initializeMachineTags(machine_id = 0) {
    $('.chips-initial').material_chip({
      placeholder: 'Enter a tag',
      secondaryPlaceholder: '+Tag',
      data: [{
        tag: 'Apple',
      }, {
        tag: 'Microsoft',
      }, {
        tag: 'Google',
      }],
    });
    // $('.chips-placeholder').material_chip({
    //   placeholder: 'Enter a tag',
    //   secondaryPlaceholder: '+Tag',
    // });
}



function showAddMachineForm(machine_id = null) {
  params = [
    { name: "machine_id", value: machine_id }
  ]
  
  $.ajax({
      url: '/v1/machines/edit_form_ajax',
      type: 'get',
      dataType: 'text',
      data: $.param(params),
      success: function(data) {
        $("#edit_form_holder").html(data);
        $("#edit_form_holder").show();
        $("#add_machine_button").hide();
      },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          alert('Error retrieving machine form: ' + textStatus);
        }
  });
}


function showMachineDetails(machine_id) {
  params = [
    { name: "machine_id", value: machine_id }
  ]
  
  $.ajax({
      url: '/v1/machines/view_form_ajax',
      type: 'get',
      dataType: 'text',
      data: $.param(params),
      success: function(data) {
        $("#edit_form_holder").html(data);
        $("#edit_form_holder").show();
        $("#add_machine_button").hide();
      },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          alert('Error retrieving machine form: ' + textStatus);
        }
  });
}



function cancelMachineEntry() {
  $("#edit_form_holder").hide();
  $("#add_machine_button").show();
}

function submitMachineCreateForm() {
      $.ajax({
          beforeSend: function(xhr) {
            var csrf = $('meta[name="csrf-token"]').attr('content');
            xhr.setRequestHeader('X-CSRF-Token', csrf);
          },
          url: '/v1/machines/save',
          type: 'post',
          dataType: 'json',
          data: $('#machine_form').serialize(),
          success: function(data) {
              $("#machine_form_holder").hide();
              $("#add_machine_button").show();
              updateMachineList();
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
              alert('Error during maching create' + textStatus);
            }
      });
}

function updateMachineList() {
  $.ajax({
      url: '/v1/machines/table_ajax',
      type: 'get',
      dataType: 'text',
      data: "",
      success: function(data) {
        $("#machine_list_holder").html(data);
      },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          alert('Error retrieving machine table: ' + textStatus);
        }
  });
}


