
const show_message = function(msg) {
  M.toast({html: msg})
}

$(document).on('ajax:error', function(event) {
  console.log('ajax loaded')
  show_message('Please fill up the required fields');
});
