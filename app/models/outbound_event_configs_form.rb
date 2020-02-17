class OutboundEventConfigsForm
  include ActiveModel::Model

  attr_accessor(
    :google_calendar_id,
    :outbound_event_configs
  )

  validate :all_outbound_event_configs_validity

  def self.model_name
    ActiveModel::Name.new(self, nil, 'OutboundEventConfig')
  end

  def initialize(params={}, user: nil)
    @user = user
    @outbound_event_configs ||= []
    super(params)
  end

  def outbound_event_configs_attributes=(outbound_event_configs_params)
    outbound_event_configs_params.each do |_i, outbound_event_config_params|
      @outbound_event_configs << user.outbound_event_configs.build(
        outbound_event_config_params.merge(
          google_calendar_id: google_calendar_id
        )
      )
    end
  end

  def user
    @user ||= User.new
  end

  def save
    return if invalid?

    outbound_event_configs.each do |outbound_event_config|
      outbound_event_config.save
    end

    true
  end

  def all_outbound_event_configs_validity
    outbound_event_configs.each_with_index do |outbound_event_config, idx|
      next if outbound_event_config.valid?
      self.errors.add("#{google_calendar_id}_receiver_id_#{idx}", "can't be blank")
    end
  end
end
