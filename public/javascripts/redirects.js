function errorRedirect(request, errorMessage) {
  if (request.status == 401) {
    window.location = "/";
  }
  
}