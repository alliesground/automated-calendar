document.addEventListener('turbolinks:before-cache', function() {
  $('select').formSelect('destroy')
})

document.addEventListener('turbolinks:load', function() {
  $('.slider').slider();
  $('.carousel').carousel();
  $('.dropdown-button').dropdown();
  $('.button-collapse').sidenav();
  //$('input, textarea').characterCounter();
  $('textarea').trigger('autoresize');
  $('select').formSelect();
  $('.datepicker').datepicker({
    selectMonths: true,
    selectYears: 15
  });
  $('.timepicker').timepicker();
  $('span.help-text').each(function() {
    var $value;
    $value = $(this)[0].innerHTML;
    $(this).addClass('hide');
    $(this).parents('div.input-field').children('label').attr('data-hint', $value);
  });
  $('.collapsible').collapsible();

  M.updateTextFields();
});
