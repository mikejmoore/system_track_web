function showAddNetworkForm(network_id = 0) {
  params = [
    { name: "network_id", value: network_id }
  ]
        
  $.ajax({
      url: '/networks/edit_form_ajax',
      type: 'get',
      dataType: 'text',
      data:     $.param(params),
      success: function(data) {
        $("#network_edit_form_holder").html(data);
        $("#network_edit_form_holder").show();
        $("#add_network_button").hide();
      },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          alert('Error retrieving machine form: ' + textStatus);
        }
  });
}

function cancelNetworkEntry() {
  $("#network_edit_form_holder").hide();
  $("#add_network_button").show();
}

function submitNetworkCreateForm() {
      $.ajax({
          beforeSend: function(xhr) {
            var csrf = $('meta[name="csrf-token"]').attr('content');
            xhr.setRequestHeader('X-CSRF-Token', csrf);
          },
          url: '/networks/save',
          type: 'post',
          dataType: 'json',
          data: $('#network_form').serialize(),
          success: function(data) {
              $("#network_form_holder").hide();
              $("#add_network_button").show();
              updateNetworkList();
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
              alert('Error during network create' + textStatus);
            }
      });
}

function updateNetworkList() {
  $.ajax({
      url: '/networks/table_ajax',
      type: 'get',
      dataType: 'text',
      data: "",
      success: function(data) {
        $("#network_list_holder").html(data);
      },
        error: function(XMLHttpRequest, textStatus, errorThrown) {
          alert('Error retrieving machine table: ' + textStatus);
        }
  });
}


