require 'rails_helper'

RSpec.describe OutboundEventProcessing, type: :model do

  let(:registrant) { create(:user) }
  let(:current_google_calendar) { create(:google_calendar, user: registrant) }
  let(:receiver) { create(:user, email: 'test2@email.com') }
  let(:event) { create(:event, user: registrant) }

  let(:outbound_event_config) do 
    create(:outbound_event_config,
           owner: registrant, 
           receiver: receiver, 
           google_calendar: current_google_calendar)
  end

  shared_context 'allow access to google calendar' do
    before do
      stub_access_to_google_calendar
    end
  end

  shared_context 'create google calendar with name matching current google calendar name' do
    let!(:receiver_google_calendar) {create(:google_calendar, user: receiver, remote_id: 'testing')}
  end

  describe '.execute' do
    context 'when receiver has allowed access to their google calendar' do
      include_context 'allow access to google calendar'

      context 'when receiver has a google calendar with name matching the current google calendar name' do
        include_context 'create google calendar with name matching current google calendar name'

        context 'when receiver has a google event associated with current event and current google calendar name'do

          let!(:google_event) do
            create(:google_event, 
                   event: event,
                   google_calendar: receiver_google_calendar)
          end

          it 'calls GoogleEventUpdater worker' do
            OutboundEventProcessing.execute(outbound_event_config, event)

            expect(GoogleEventUpdater).to have_enqueued_sidekiq_job(
              event.id,
              receiver_google_calendar.remote_id,
              google_event.remote_id,
              receiver.id
            )
          end
        end

        context 'when receiver does not have a google event associated with current event and current google calendar name'do
          it 'creates a google event' do
            OutboundEventProcessing.execute(outbound_event_config, event)

            google_event = event.
                           google_events.
                           by_user(receiver).
                           by_calendar_name(current_google_calendar.name).
                           first

            expect(google_event).to_not be nil
          end
        end

      end
    end
  end
end
