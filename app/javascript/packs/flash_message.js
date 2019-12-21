
const show_message = msg => {
  M.toast({html: msg})
}

$(document).on('ajax:complete', function(event) {
  const xhr = event.detail[0];
  const msg = xhr.getResponseHeader('Message');

  if(msg) show_message(msg);
});
