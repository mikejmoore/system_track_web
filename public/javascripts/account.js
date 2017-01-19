
function showEnvironmentsEntryForm(account_id) {
  params = [
    { name: "account_id", value: account_id }
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

var __maxIndexDetected = 0;

function findNextEnvironmentIndex() {
  var maxIndex = 1;
  var holder = $("#environments_holder");
  var children = holder.children();
  for (var i = 0; i < children.length; i++) {
    var child = children[i];
    var childId = $(child).attr('id');
    if (childId.startsWith("environment_row_")) {
      var indexStr = childId.substring(16, childId.length);
      var childIndex = parseInt(indexStr);
      if (childIndex > maxIndex) {
        maxIndex = childIndex;
      }
    }
  }
  if (maxIndex > __maxIndexDetected) {
    __maxIndexDetected = maxIndex;
  }
  __maxIndexDetected += 1;
  return __maxIndexDetected;
}


function addEnvironmentEntry() {
  var holder = $("#environments_holder");
  var index = findNextEnvironmentIndex();
  params = [
    { name: "index", value: index }
  ]
  $.ajax({
      url: '/accounts/environment_row',
      type: 'get',
      dataType: 'text',
      data:     $.param(params),
      success: function(data) {
        holder.html(holder.html() + data);
        Materialize.updateTextFields();
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
        alert('Error retrieving environment entry: ' + textStatus + " -- " + errorThrown);
      }
  });
}


function deleteEnvironment(element_js_id) {
  element_js_id = "#" + element_js_id;
  $(element_js_id).remove();
}

function submitAccountForm() {
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


