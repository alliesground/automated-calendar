import 'materialize-css/dist/js/materialize';

$(document).on('turbolinks:load', function() {

  const generateUserSelect = (users) => {

    var userSelect = document.createElement('select');

    var placeholder = document.createElement('option');
    placeholder.text = 'Please select a receiver';
    placeholder.value = "";
    placeholder.placeholder = true;
    userSelect.appendChild(placeholder);

    users.forEach(function(user) {
      userSelect.options[userSelect.options.length] = new Option(
        user.email, 
        user.id
      )
    })

    return userSelect;
  }

  const cacheSelectedReceiver = (configsContainerId, receiverId) => {
    configs[configsContainerId][receiverId] = {receiverId: receiverId}
  }

  var configs = {}

  $('.configs').each(function() {
    var configsContainerId = $(this).data('configs-container-id');

    configs[configsContainerId] = {}

    $(this).children('[data-id]').each(function(i, ele) {
      cacheSelectedReceiver(configsContainerId, $(this).data('id'));
    })
  });

  /* Filtering out selected users */
  const removeSelectedReceiverOptions = (userSelect, currentConfigsContainerId) => {
    var $userSelect = $(userSelect);

    for(const config of Object.values(configs[currentConfigsContainerId])) {
      var $option = $userSelect.children("option[value='" + config.receiverId + "']")
      if(!$option.is(':selected')) $option.remove();
    }

    return $userSelect;
  }

  $('form').on('click', '.add-btn', function() {
    var $that = $(this);
    var currentConfigsContainerId = $(this).closest('.configs').data('configs-container-id');

    $.get('/users')
      .then(generateUserSelect)
      .then((userSelect) => removeSelectedReceiverOptions(userSelect, currentConfigsContainerId))
      .then(function( $userSelect ) {

        var $form = $that.parents('.configs form');

        $("<div class='row'><div class='col s12'></div></div>")
          .find('div.col')
          .html($userSelect)
          .parents()
          .insertBefore($form.find('.row:last'));

        $userSelect.formSelect();

        return $userSelect;
      })
      .then(function($userSelect) {
        var previousSelectedVal = $userSelect.val();
        var previousSelectedText = $userSelect.find('option:selected').text();

        $userSelect.on('change', function() {
          var $that = $(this);
          // remove previous selected option from configs
          delete configs[currentConfigsContainerId][previousSelectedVal]

          // add new selected option to configs
          if($(this).val()) {
            cacheSelectedReceiver(currentConfigsContainerId, $(this).val())
          }

          var $siblingSelects = $(this).parents('.row:first').siblings().find('select');
          console.log('Select: ', $(this).parents('.row:first').siblings().find('select'));

          // update sibling select's options
          $siblingSelects.each(function() {
            var $newSelect = removeSelectedReceiverOptions($(this).get(0), currentConfigsContainerId);

            if(previousSelectedVal) {
              $newSelect.append(new Option(previousSelectedText, previousSelectedVal));
            }

            $(this).replaceWith($newSelect).formSelect();
          });

          previousSelectedVal = $(this).val();
          previousSelectedText = $(this).find('option:selected').text();
        })
      })
  });
});
