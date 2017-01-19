function showAddServiceForm(service_id = 0) {
  params = [
    { name: "service_id", value: service_id }
  ]
        
  $.ajax({
      url: '/services/edit_form_ajax',
      type: 'get',
      dataType: 'text',
      data:     $.param(params),
      success: function(data) {
        $("#service_edit_form_holder").html(data);
        $("#service_edit_form_holder").show();
        $("#add_service_button").hide();
      },
        error: function(request, textStatus, errorThrown) {
          errorRedirect(request, textStatus)
        }
  });
}


function cancelServiceEntry() {
  $("#service_edit_form_holder").hide();
  $("#add_service_button").show();
}


function submitServiceCreateForm() {
      $.ajax({
          beforeSend: function(xhr) {
            var csrf = $('meta[name="csrf-token"]').attr('content');
            xhr.setRequestHeader('X-CSRF-Token', csrf);
          },
          url: '/services/save',
          type: 'post',
          dataType: 'json',
          data: $('#service_form').serialize(),
          success: function(data) {
              $("#service_form_holder").hide();
              $("#add_service_button").show();
              updateServiceList();
            },
            error: function(request, textStatus, errorThrown) {
              errorRedirect(request, textStatus)
            }
      });
}

function updateServiceList() {
  $.ajax({
      url: '/services/table_ajax',
      type: 'get',
      dataType: 'text',
      data: "",
      success: function(data) {
        $("#service_list_holder").html(data);
      },
      error: function(request, textStatus, errorThrown) {
        errorRedirect(request, textStatus)
      }
  });
}


