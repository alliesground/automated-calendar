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

  let!(:outbound_event_processing) do
    OutboundEventProcessing.new(outbound_event_config, event)
  end

  shared_context 'allow access to google calendar' do
    before do
      allow(GoogleCalendarConfig).to receive(:authorized_by?).with(any_args).and_return(true)
    end
  end

  shared_context 'create google calendar with name matching current google calendar' do
    let!(:google_calendar) {create(:google_calendar, user: receiver, remote_id: 'testing')}
  end

  describe '#start' do

    context 'when event receiver has allowed access to their google calendar' do
      include_context 'allow access to google calendar'

      context 'when receiver has a google calendar with name matching given google calendar name' do
        include_context 'create google calendar with name matching current google calendar'

        it 'enqueus GoogleEventCreator worker job' do
          outbound_event_processing.start

          expect(GoogleEventCreator).to have_enqueued_sidekiq_job(
            event.id,
            google_calendar.id,
            receiver.id
          )
        end
      end

      context 'when receiver does not have a google calendar with matching current google calendar name' do

        it 'creates local google calendar for event receiver' do
          expect{ outbound_event_processing.start }.to change { GoogleCalendar.count }.by(1) 
        end

        it 'enqueus GoogleCalendarCreator worker job' do
          outbound_event_processing.start

          expect(GoogleCalendarCreator).to have_enqueued_sidekiq_job(
            receiver.google_calendars.last.id,
            receiver.google_calendars.last.name,
            receiver.id
          )
        end

        it 'enqueus GoogleEventCreator worker job after GoogleCalendarCreator worker successfully executes' do
          outbound_event_processing.start

          b = Sidekiq::Batch.new
          b.on(:success,
               OutboundEventProcessing::CalendarCreationCallback,
               'google_calendar_id' => receiver.google_calendars.last.id,
               'receiver_id' => receiver.id,
               'event_id' => event.id)

          OutboundEventProcessing::CalendarCreationCallback.new.on_success(
            Sidekiq::Batch::Status.new(b.bid),
            {
              'google_calendar_id' => receiver.google_calendars.last.id,
              'receiver_id' => receiver.id,
              'event_id' => event.id
            }
          )

          expect(GoogleEventCreator).to have_enqueued_sidekiq_job(
            Event.last.id,
            receiver.google_calendars.last.id,
            receiver.id
          )

          expect(GoogleEventCreator.jobs.last['args'][1]).not_to be_nil
        end
      end
    end

    context 'when event receiver has not allowed access to their google calendar' do
        before do
          allow(GoogleCalendarConfig).to receive(:authorized_by?).with(any_args).and_return(false)
        end

        include_context 'create google calendar with name matching current google calendar'

        it 'does not enqueu GoogleEventCreator worker job' do
          outbound_event_processing.start
          expect(GoogleEventCreator.jobs.size).to eq 0
        end
    end
  end

  describe '#update' do
    context 'when event receiver has allowed access to their google calendar' do
      include_context 'allow access to google calendar'

      context 'when receiver has a google calendar with name matching given google calendar name' do
        include_context 'create google calendar with name matching current google calendar'
        
        context "when receiver's google calendar has the google event" do
          let!(:google_event) do 
            create(:google_event,
                   event: event,
                   google_calendar: google_calendar)
          end

          it 'calls GoogleEventUpdater worker' do
            outbound_event_processing.update

            expect(GoogleEventUpdater).to have_enqueued_sidekiq_job(
              Event.last.id,
              receiver.google_calendars.last.remote_id,
              google_event.remote_id,
              receiver.id
            )
          end
        end

        context "when receiver's google calendar does not have the google event" do
          it 'calls GoogleEventCreator worker' do
            outbound_event_processing.update

            expect(GoogleEventCreator).to have_enqueued_sidekiq_job(
              Event.last.id,
              receiver.google_calendars.last.id,
              receiver.id
            )
          end
        end
      end
    end
  end
end
