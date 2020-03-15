require 'rails_helper'

RSpec.describe EventRegistration, type: :model do
  let(:registrant) { create(:user) }
  let!(:registrant_google_calendar) { create(:google_calendar, user: registrant) }
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
  let(:outbound_event_receiver) { create(:user, email: 'test2@email.com') }

  shared_context 'configure outbound_event_config' do
    before do
      create(:outbound_event_config, 
             owner: registrant, 
             receiver: outbound_event_receiver,
             google_calendar: registrant_google_calendar)
    end
  end

  shared_context 'allow access to google calendar' do
    before do
      allow(GoogleCalendarConfig).to receive(:authorized_by?).with(any_args).and_return(true)
    end
  end

  describe '#save' do
    let(:event_registration) { EventRegistration.new(registrant: registrant) }

    context 'with valid arguments' do
      context 'when registrant has outbound events configured' do
        include_context 'configure outbound_event_config'

        it 'starts outbound event processing' do

          expect_any_instance_of(OutboundEventProcessing).to receive(:start).with(no_args)
          event_registration.save(params)
        end
      end
    end
  end

  describe '#update' do

    let!(:registrant_event) { create(:event, user: registrant) }
    let(:registrant_another_google_calendar) do 
      create(:google_calendar, 
             user: registrant, 
             name: 'another test calendar') 
    end

    let!(:registrant_google_events) do
      [create(:google_event,
              event: registrant_event,
              google_calendar: registrant_google_calendar)]
    end

    let(:event_registration) do
      EventRegistration.new(
        event: registrant_event,
        registrant: registrant
      ) 
    end

    context 'with valid arguments' do
      let(:update_params) do
        params.merge(
          title: 'updated title',
          google_calendar_id: registrant_another_google_calendar.id
        )
      end

      it 'updates local event' do
        event_registration.update(update_params)

        expect(registrant_event.title).to eq update_params[:title]
      end

      context 'when registrant has outbound events configured' do
        include_context 'configure outbound_event_config'

        it 'assigns update task for outbound events to OutboundEventProcessing #update' do
          expect_any_instance_of(OutboundEventProcessing).to receive(:update).with(no_args)

          event_registration.update(update_params)
        end
      end

      context 'when registrant has allowed access to google calendar' do
        include_context 'allow access to google calendar'

        context 'when calendar is changed' do

          it 'destroys the google event associated with current event and previous calendar' do

            expect{
              event_registration.update(update_params)
            }.to change{GoogleEvent.count}.by -1
          end

          it 'calls GoogleEventCreator worker to create new google_event associated with current event and new calendar' do

            event_registration.update(update_params)

            expect(GoogleEventCreator).to have_enqueued_sidekiq_job(
              registrant_event.id,
              registrant_another_google_calendar.id,
              registrant.id
            )
          end
        end

        context 'when calendar is not changed' do
          it 'enqueus GoogleEventUpdater worker job' do
            event_registration.update(params)

            expect(GoogleEventUpdater).to have_enqueued_sidekiq_job(
              registrant_event.id,
              registrant_google_calendar.remote_id,
              registrant_google_events.first.remote_id,
              registrant.id
            )
          end
        end
      end
    end
  end
end
