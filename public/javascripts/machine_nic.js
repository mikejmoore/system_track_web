function showAddNicForm(machineId, machineNicId) {
  params = [
    { name: "machine_id", value: machineId },
    { name: "machine_nic_id", value: machineNicId }
  ]
  
  $.ajax({
      url: '/v1/machines/nic_edit_form_ajax',
      type: 'get',
      dataType: 'text',
      data: $.param(params),
      success: function(data) {
        $("#entry_holder").show();
        $("#entry_holder").html(data);
        $("#add_nic_button").hide();
//        $("#save_button_row").show();
        $("#machine_buttons").hide();
      },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          alert('Error showing nic entry form: ' + textStatus);
        }
  });
  
}


function saveMachineNetworkCard() {
  $("#entry_holder").hide();
  $("#add_nic_button").show();
//  $("#save_button_row").hide();
  $("#machine_buttons").show();
  
  $.ajax({
      beforeSend: function(xhr) {
        var csrf = $('meta[name="csrf-token"]').attr('content');
        xhr.setRequestHeader('X-CSRF-Token', csrf);
      },
      url: '/v1/machines/save_network_card',
      type: 'post',
      dataType: 'text',
      data: $('#machine_nic_form').serialize(),
      success: function(data) {
          $("#nic_table_holder").html(data);
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
          alert('Error submitting nic form: ' + textStatus);
      }
  });
  
}

function cancelNetworkCardEdit() {
  $("#entry_holder").hide();
  $("#add_nic_button").show();
  //$("#save_button_row").hide();
  $("#machine_buttons").show();
}

function deleteMachineNetworkCard(nicId) {
  params = [
    { name: "network_card_id", value: nicId }
  ]
  
  $.ajax({
      beforeSend: function(xhr) {
        var csrf = $('meta[name="csrf-token"]').attr('content');
        xhr.setRequestHeader('X-CSRF-Token', csrf);
      },
      url: '/v1/machines/delete_network_card',
      type: 'delete',
      dataType: 'text',
      data: $.param(params),
      success: function(data) {
          $("#nic_table_holder").html(data);
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
          alert('Error deleting nic: ' + textStatus);
      }
  });
}


function editMachineNetworkCard(machineId, networkCardId) {
  nicRow = $("#nic_row_" + networkCardId);
  
  params = [
    { name: "machine_id", value: machineId },
    { name: "machine_nic_id", value: networkCardId }
  ]
  
  $.ajax({
      url: '/v1/machines/nic_edit_form_ajax',
      type: 'get',
      dataType: 'text',
      data: $.param(params),
      success: function(data) {
        nicRow.html(data);
        Materialize.updateTextFields();
        $("#add_nic_button").hide();
      },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          alert('Error showing nic entry form: ' + textStatus);
        }
  });
  
}




