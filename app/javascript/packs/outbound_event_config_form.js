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
        $userSelect.insertBefore($that.closest('.row'));
        $userSelect.formSelect();

        $that.closest('.row').prev('.select-wrapper').wrap("<div class='row'></div>");
        return $userSelect;
      })
      .then(function($userSelect) {
        var previousSelectedVal = $userSelect.val();
        var previousSelectedText = $userSelect.find('option:selected').text();
        $userSelect.parents('form:first').on('change', $userSelect, function() {
          console.log('Still Alive');
        })

        $userSelect.on('change', function() {
          var $that = $(this);
          // remove previous selected option from configs
          delete configs[currentConfigsContainerId][previousSelectedVal]

          // add new selected option to configs
          if($(this).val()) {
            cacheSelectedReceiver(currentConfigsContainerId, $(this).val())
          }

          var $siblingSelectWrappers = $userSelect.parents('.row:first').siblings('div.row').not('div.row:last');

          // update sibling select's options
          $siblingSelectWrappers.each(function() {
            var $newSelect = removeSelectedReceiverOptions($(this).find('select').get(0), currentConfigsContainerId);

            if(previousSelectedVal) {
              $newSelect.append(new Option(previousSelectedText, previousSelectedVal));
            }

            $(this).find('select').replaceWith($newSelect).formSelect();
          });

          previousSelectedVal = $(this).val();
          previousSelectedText = $(this).find('option:selected').text();
        })
      })
  });
});
