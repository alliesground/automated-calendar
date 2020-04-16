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
      stub_access_to_google_calendar
    end
  end

  describe '#save' do
    let(:event_registration) { EventRegistration.new(registrant: registrant) }

    context 'with valid arguments' do
      context 'when registrant has outbound events configured' do
        include_context 'configure outbound_event_config' do
          let(:google_calendar) { registrant_google_calendar }
        end

        it 'starts outbound event processing' do
          expect(OutboundEventProcessing).to receive(:execute)

          event_registration.save(params)
        end
      end

      context 'when registrant has allowed access to their google calendar' do
        include_context 'allow access to google calendar'

        it 'creates google event' do
          expect{
            event_registration.save(params)
          }.to change{GoogleEvent.count}.by 1
        end

        it 'calls GoogleEventCreator worker with corrent args' do
          event_registration.save(params)

          expect(GoogleEventCreator).to have_enqueued_sidekiq_job(
            GoogleEvent.last.id
          )
        end
      end
    end
  end

  describe '#update' do

    let(:update_params) do
      params.merge(
        title: 'updated title'
      )
    end 

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
      ) end

    shared_context 'update params with new calendar' do
      let(:update_params_with_calendar_change) do
        params.merge(
          title: 'updated title',
          google_calendar_id: registrant_another_google_calendar.id
        )
      end
    end

    context 'with valid arguments' do

      it 'updates local event' do
        event_registration.update(update_params)

        expect(registrant_event.title).to eq update_params[:title]
      end

      context 'when registrant has allowed access to their google calendar' do
        include_context 'allow access to google calendar'

        context 'when registrant has a google event associated with current event and current calendar' do

          it 'calls GoogleEventUpdater worker' do

            event_registration.update(update_params)

            expect(GoogleEventUpdater).to have_enqueued_sidekiq_job(
              registrant_event.id,
              registrant_google_calendar.remote_id,
              registrant_google_events.first.remote_id,
              registrant.id
            )
          end
        end

        context 'when registrant does not have google event associated with current event and current calendar' do
          include_context 'update params with new calendar'

          it 'creates a google event for the registrant associated with current event and new calendar' do
            event_registration.update(update_params_with_calendar_change)

            google_event = registrant_event.
                            google_events.
                            by_user(registrant).
                            by_calendar_name(registrant_another_google_calendar.name)

            expect(google_event.count).to_not be nil
          end
        end

      end

      context 'when registrant has outbound events configured' do
        include_context 'configure outbound_event_config'

        it 'executes OutboundEventProcessing' do
          expect(OutboundEventProcessing).to receive(:execute)

          event_registration.update(update_params)
        end
      end

      context 'when calendar is changed' do
        include_context 'update params with new calendar' 

        context 'when users have allowed access to their google calendar' do
          include_context 'allow access to google calendar'

          it 'destroys all local google_events associated with current event and previous calendar name for all users' do

            event_registration.update(update_params_with_calendar_change)

            google_events = registrant_event.
                            google_events.
                            by_calendar_name(
                              registrant_google_calendar.name
                            )

            expect(google_events.count).to be 0
          end
        end
      end
    end
  end
end
