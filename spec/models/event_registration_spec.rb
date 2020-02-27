require 'rails_helper'

RSpec.describe EventRegistration, type: :model do
  describe '#save' do
    let(:registrar) { create(:user) }
    let(:event_registration) { EventRegistration.new(registrar: registrar) }
    let(:params) do
      {
        title: 'test event',
        event_start_date: 'Fed 03, 2020',
        event_end_date: 'Fed 03, 2020',
        event_start_time: '01:00 PM',
        event_end_time: '02:00 PM',
        google_calendar_id: 1
      }
    end
    let(:receiver) { create(:user, email: 'test2@email.com') }
    let(:registrar_google_calendar) { create(:google_calendar, user: registrar) }

    context 'when the registrar has outbound event configured for the current calendar to which the event was registered' do
      let(:outbound_event_config) do
        create(:outbound_event_config, owner: registrar, receiver: receiver, google_calendar: registrar_google_calendar )
      end

      context 'if the outbound event receiver has the current calendar' do
        let(:receiver_google_calendar) { create(:google_calendar, user: receiver) }
        it 'calls GoogleCalendarEventCreator background worker' do
          binding.pry
          event_registration.save(params)
          worker = class_double("GoogleCalendarEventCreator")
          expect(worker).to receive(:perform_async).with(any_args)
        end
      end
    end
  end
end
