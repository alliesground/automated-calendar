
const show_message = msg => {
  M.toast({html: msg})
}

$(document).on('ajax:complete', function(event) {
  const xhr = event.detail[0]
  show_message(xhr.getResponseHeader('Message'))
});
