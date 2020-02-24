import 'materialize-css/dist/js/materialize';

let configsContainers = {}

const initializeSelectedReceiversFor = ($configsContainer) => {

  var configsContainerId = $configsContainer.data('configs-container-id');

  configsContainers[configsContainerId] = {
    selectedReceivers: [],
    addToSelectedReceivers: function(receiverId) {
      this.selectedReceivers.push(parseInt(receiverId, 10));
    },
    removeFromSelectedReceivers: function (receiverId) {
      var receiverId = parseInt(receiverId, 10)
      var idx = this.selectedReceivers.indexOf(receiverId);
      this.selectedReceivers.splice(idx, 1);
    }
  }

  $configsContainer.find('[data-config-id]').each(function() {
    var configId = $(this).data('config-id');
    var receiverId = $(this).find('[data-config-receiver-id]').data('config-receiver-id');

    if(!configsContainers[configsContainerId]
      .selectedReceivers
      .includes(receiverId)) {

      configsContainers[configsContainerId]
        .addToSelectedReceivers(receiverId);
    }
  });
}

const initializeAllSelectedReceivers = () => {
  $('.configs').each(function() {
    initializeSelectedReceiversFor($(this));
  });
}

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

/* Filtering out selected users */
const removeSelectedReceiverOptions = (userSelect, configsContainerId) => {
  var $userSelect = $(userSelect);

  configsContainers[configsContainerId].selectedReceivers.forEach((selectedReceiverId) => {
    var $option = $userSelect.children("option[value='" + selectedReceiverId + "']");
    if(!$option.is(':selected')) $option.remove();
  }); 

  return $userSelect;
}

const addNameAttr = (userSelect, configsContainerId) => {
  var $configsContainer = $("[data-configs-container-id='" + configsContainerId + "']")

  var selectCount = $configsContainer.find('select').length;

  userSelect.setAttribute(
    'name', 
    'outbound_event_configs_form[outbound_event_configs_attributes]' + 
      '[' + selectCount + '][receiver_id]'
  );

  return userSelect;
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
    .appendTo(
      $targetConfigsContainer.find('.new-configs-holder div:first')
    );

  $userSelect.formSelect();

  return $userSelect;
}

const addSelectOptionTo = ($select, optionVal, optionTxt) => {
  if(optionVal) {
    $select.append(new Option(optionTxt, optionVal))
  }
  $select.formSelect();
}

const removeSelectOptionFor = ($select, optionVal) => {}

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
    'outbound_event_configs_form_' + configsContainerId + '_receiver_id_' + selectCount
  );

  return userSelect;
}

const resetIdAttrs = (configsContainerId) => {
  var $configsContainer = $("[data-configs-container-id='" + configsContainerId + "']");
  $configsContainer.find('select').each(function(idx) {
    $(this).attr('id', 'outbound_event_configs_form_' + configsContainerId + '_receiver_id_' + idx)
  });
}

const resetNameAttrs = (configsContainerId) => {
  var $configsContainer = $("[data-configs-container-id='" + configsContainerId + "']");
  $configsContainer.find('select').each(function(idx) {
    $(this)
      .attr(
        'name', 
        'outbound_event_configs_form[outbound_event_configs_attributes]' + 
          '[' + idx + '][receiver_id]'
      )
  });
}

const enableSubmit  = ($that) => {
  $that.siblings(':submit').removeClass('disabled');
}

const disableSubmit = ($that) => {
  $that
    .parents('.configs')
    .find('.actions')
    .find(':submit')
    .addClass('disabled');
}

$(document).on('turbolinks:load', function() {

  initializeAllSelectedReceivers();

  $('form').on('click', '.add-btn', function() {

    var $that = $(this);
    var currentConfigsContainerId = $(this).closest('.configs').data('configs-container-id');

    $.get('/users')
      .then(generateUserSelect)
      .then((userSelect) => addIdAttr(userSelect, currentConfigsContainerId))
      .then((userSelect) => addNameAttr(userSelect, currentConfigsContainerId))
      .then((userSelect) => removeSelectedReceiverOptions(userSelect, currentConfigsContainerId))
      .then(($userSelect) => insert($userSelect, currentConfigsContainerId))
      .then(function($userSelect) {
        var previousSelectedVal = $userSelect.val();
        var previousSelectedText = $userSelect.find('option:selected').text();

        $userSelect.on('change', function() {
          var $that = $(this);

          if(previousSelectedVal) {
            configsContainers[currentConfigsContainerId]
              .removeFromSelectedReceivers(previousSelectedVal);
          }

          if($(this).val()) {
            configsContainers[currentConfigsContainerId].addToSelectedReceivers($(this).val())
          }

          updateSiblingSelectsOption($(this), previousSelectedVal, previousSelectedText);

          previousSelectedVal = $(this).val();
          previousSelectedText = $(this).find('option:selected').text();
        })
      })
      .then(enableSubmit($that))
  });

  $('form').on('click', '.cancel-config', function(e) {
    e.preventDefault();

    var selects = $(this).parents('.row:first').siblings().find('select');
    if(!selects.length) disableSubmit($(this));

    var currentConfigsContainerId = $(this).closest('.configs').data('configs-container-id');
    var selectedVal = $(this).parents('.row:first').find('select').val();
    var selectedText = $(this).parents('.row:first').find('option:selected').text();

    if(selectedVal) {

      configsContainers[currentConfigsContainerId]
        .removeFromSelectedReceivers(selectedVal);

      updateSiblingSelectsOption($(this), selectedVal, selectedText);
    }

    $(this).parents('.row:first').remove();
    resetIdAttrs(currentConfigsContainerId);
    resetNameAttrs(currentConfigsContainerId);
  });

  $('form').on('ajax:success', function() {
    initializeSelectedReceiversFor($(this).parent());

    disableSubmit($(this));
  });

  var $deleteConfigLink = 
    $('.existing-configs-holder')
    .find('a');

  $deleteConfigLink.on('ajax:success', function() {
    var currentConfigsContainerId = 
      $(this).parents('.configs:first')
      .data('configs-container-id')

    var receiverId = $(this).parent().data('config-receiver-id');
    var receiverEmail = $(this).parent().contents()[0].nodeValue;

    configsContainers[currentConfigsContainerId]
      .removeFromSelectedReceivers(receiverId);

    $(this).parents('.configs:first').find('select').each(function() {
      addSelectOptionTo($(this), receiverId, receiverEmail);
    });

  });
});
