import 'materialize-css/dist/js/materialize';

$(document).on('turbolinks:load', function() {

  var configs = {}

  $('.configs').each(function() {
    var configsContainerId = $(this).data('configs-container-id');

    configs[configsContainerId] = {}

    $(this).children('[data-id]').each(function(i, ele) {
      addToConfigs(configsContainerId, $(this).data('id'));
    })
  });

  const generateUserSelect = (users) => {

    var userSelect = document.createElement('select');
    userSelect.setAttribute('name', 'outbound_event_config[receiver_ids][]');

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

  const addToConfigs = (configsContainerId, key) => {
    configs[configsContainerId][key] = {receiverId: key}
  }

  const removeFromConfigs = (configsContainerId, key) => {
    delete configs[configsContainerId][key]
  }

  /* Filtering out selected users */
  const removeSelectedReceiverOptions = (userSelect, currentConfigsContainerId) => {
    var $userSelect = $(userSelect);

    for(const config of Object.values(configs[currentConfigsContainerId])) {
      var $option = $userSelect.children("option[value='" + config.receiverId + "']")
      if(!$option.is(':selected')) $option.remove();
    }

    return $userSelect;
  }

  const insert = ($userSelect, targetConfigsContainerId) => {
    var $targetConfigsContainer = 
      $('[data-configs-container-id="' + 
        targetConfigsContainerId +'"]');

    $(
      `
        <div class='row valign-wrapper'>
          <div class='col s11'></div>
          <div class='col s1 right-align'>
            <a href='#' style='color: red' class='cancel-config'>
              <i class='small material-icons'>cancel</i>
            </a>
          </div>
        </div>
      `
    )
      .find('div.col:first')
      .html($userSelect)
      .parents()
      .insertBefore(
        $targetConfigsContainer.find('form .row:last')
      );

    $userSelect.formSelect();

    return $userSelect;
  }

  // update sibling selects option
  const updateSiblingSelectsOption = ($sourceEle, optionVal, optionTxt) => {
    var $siblingSelects = $sourceEle.parents('.row:first').siblings().find('select');
    var currentConfigsContainerId = $sourceEle.closest('.configs').data('configs-container-id');

    $siblingSelects.each(function() {
      var $newSelect = removeSelectedReceiverOptions($(this).get(0), currentConfigsContainerId);

      if(optionVal) {
        $newSelect.append(new Option(optionTxt, optionVal));
      }

      $(this).replaceWith($newSelect).formSelect();
    });
  }

  const addIdAttr = (userSelect, configsContainerId) => {
    var $configsContainer = $("[data-configs-container-id='" + configsContainerId + "']")

    var selectCount = $configsContainer.find('select').length;


    userSelect.setAttribute(
      'id', 
      'outbound_event_config_' + configsContainerId + '_receiver_id_' + selectCount
    );

    return userSelect;
  }

  const resetIdAttrs = (configsContainerId) => {
    var $configsContainer = $("[data-configs-container-id='" + configsContainerId + "']");
    $configsContainer.find('select').each(function(idx) {
      $(this).attr('id', 'outbound_event_config_' + configsContainerId + '_receiver_id_' + idx)
    });
  }

  $('form').on('click', '.add-btn', function() {
    var $that = $(this);
    var currentConfigsContainerId = $(this).closest('.configs').data('configs-container-id');

    $.get('/users')
      .then(generateUserSelect)
      .then((userSelect) => addIdAttr(userSelect, currentConfigsContainerId))
      .then((userSelect) => removeSelectedReceiverOptions(userSelect, currentConfigsContainerId))
      .then(($userSelect) => insert($userSelect, currentConfigsContainerId))
      .then(function($userSelect) {
        var previousSelectedVal = $userSelect.val();
        var previousSelectedText = $userSelect.find('option:selected').text();

        $userSelect.on('change', function() {
          var $that = $(this);

          removeFromConfigs(currentConfigsContainerId, previousSelectedVal)

          if($(this).val()) {
            addToConfigs(currentConfigsContainerId, $(this).val())
          }

          updateSiblingSelectsOption($(this), previousSelectedVal, previousSelectedText);

          previousSelectedVal = $(this).val();
          previousSelectedText = $(this).find('option:selected').text();
        })
      })
  });

  $('form').on('click', '.cancel-config', function(e) {
    e.preventDefault();

    var currentConfigsContainerId = $(this).closest('.configs').data('configs-container-id');
    var selectedVal = $(this).parents('.row:first').find('select').val();
    var selectedText = $(this).parents('.row:first').find('option:selected').text();

    if(selectedVal) {

      removeFromConfigs(currentConfigsContainerId, selectedVal);

      updateSiblingSelectsOption($(this), selectedVal, selectedText);
    }

    $(this).parents('.row:first').remove();
    resetIdAttrs(currentConfigsContainerId);
  });
});
