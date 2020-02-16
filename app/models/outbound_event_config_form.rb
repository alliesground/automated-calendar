class OutboundEventConfigForm
  include ActiveModel::Model

  attr_accessor :receiver_ids
  attr_accessor :google_calendar_id

  validate :receiver_ids_presence

  def self.model_name
    ActiveModel::Name.new(self, nil, 'OutboundEventConfig')
  end

  def initialize(params={}, user: nil)
    super(params)
    @receiver_ids ||= []
    @user = user
  end

  def configs_for(google_calendar:)
    google_calendar.outbound_event_configs
  end

  def user
    @user ||= User.new
  end

  def save
    return if invalid?
    receiver_ids.each do |receiver_id|
      user.outbound_event_configs.where(
        receiver_id: receiver_id,
        google_calendar_id: google_calendar_id
      ).first_or_create
    end
    true
  end

  def outbound_event_config(receiver_id)
    user.outbound_event_configs.find_by(
      receiver_id: receiver_id,
      google_calendar_id: google_calendar_id
    )
  end

  def receiver_ids_presence
    receiver_ids.each_with_index do |receiver_id, idx|
      if receiver_id.empty?
        self.errors.add("#{google_calendar_id}_receiver_id_#{idx}", "can't be empty")
      end
    end
  end
end
