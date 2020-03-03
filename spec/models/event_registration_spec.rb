require 'rails_helper'

RSpec.describe EventRegistration, type: :model do
  describe '#save' do
    let(:registrant) { create(:user) }
    let(:event_registration) { EventRegistration.new(registrant: registrant) }
    let(:registrant_google_calendar) { create(:google_calendar, user: registrant) }
    let(:receiver) { create(:user, email: 'test2@email.com') }

    let(:params) do
      {
        title: 'test event',
        event_start_date: 'Fed 03, 2020',
        event_end_date: 'Fed 03, 2020',
        event_start_time: '01:00 PM',
        event_end_time: '02:00 PM',
        google_calendar_id: registrant_google_calendar.id
      }
    end

    context 'with valid arguments' do
      context 'when registrant has outbound events configured' do
        before do
          create(:outbound_event_config, 
                 owner: registrant, 
                 receiver: receiver, 
                 google_calendar: registrant_google_calendar)
        end

        it 'starts outbound event processing' do

          expect_any_instance_of(OutboundEventProcessing).to receive(:start).with(no_args)
          event_registration.save(params)
        end
      end
    end
  end
end
