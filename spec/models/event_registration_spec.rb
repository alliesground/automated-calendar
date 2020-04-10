require 'rails_helper'

RSpec.describe EventRegistration, type: :model do
  let(:registrant) { create(:user) }
  let(:receiver) { create(:user, email: 'receiver@email.com') }
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
             google_calendar: google_calendar)
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
        include_context 'configure outbound_event_config' do
          let(:google_calendar) { registrant_google_calendar }
        end

        it 'starts outbound event processing' do

          expect_any_instance_of(OutboundEventProcessing).to receive(:start).with(no_args)
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

    let(:update_params_with_calendar_change) do
      params.merge(
        title: 'updated title',
        google_calendar_id: registrant_another_google_calendar.id
      )
    end

    let!(:registrant_event) { create(:event, user: registrant) }
    let(:registrant_another_google_calendar) do 
      create(:google_calendar, 
             user: registrant, 
             name: 'another test calendar') 
    end
    let!(:receiver_google_calendar) { create(:google_calendar,
                                             user: receiver) }

    let!(:registrant_google_events) do
      [create(:google_event,
              event: registrant_event,
              google_calendar: registrant_google_calendar)]
    end
    let!(:receiver_google_events) do
      [create(:google_event,
              event: registrant_event,
              google_calendar: receiver_google_calendar)]
    end

    let(:event_registration) do
      EventRegistration.new(
        event: registrant_event,
        registrant: registrant
      ) end

    context 'with valid arguments' do

      it 'updates local event' do
        event_registration.update(update_params)

        expect(registrant_event.title).to eq update_params[:title]
      end

      context 'when calendar is changed' do
        let(:update_params) do
          params.merge(
            title: 'updated title',
            google_calendar_id: registrant_another_google_calendar.id
          )
        end

        describe 'destroying google_events associated with previous calendar' do
          context 'when users have allowed access to their google calendar' do
            include_context 'allow access to google calendar'

            it 'destroys all local google_events associated with current event and previous calendar name for all users' do

              event_registration.update(update_params)

              google_events = Event.
                              last.
                              google_events.
                              by_calendar_name(
                                registrant_google_calendar.name
                              )

              expect(google_events.count).to be 0
            end

            it 'calls GoogleEventDestroyer worker for each google_events associated with current event and previous calendar name for all users' do
              event_registration.update(update_params)

              expect(GoogleEventDestroyer).to have_enqueued_sidekiq_job(
                registrant.id,
                registrant_google_calendar.remote_id,
                registrant_google_events.first.remote_id
              )
            end

          end
        end

        describe 'creating google event for registrant' do
          context 'when registrant has allowed access to their google calendar' do
            include_context 'allow access to google calendar'

            it 'calls GoogleEventCreator worker for registrant' do

              event_registration.update(update_params)

              expect(GoogleEventCreator).to have_enqueued_sidekiq_job(
                GoogleEvent.last.id
              )
            end
          end
        end

        describe 'staring outbound events creation for new calendar' do
          context 'when registrant has outbound events configured' do
            include_context 'configure outbound_event_config' do
              let(:google_calendar) { registrant_another_google_calendar }
            end

            it 'calls OutboundEventProcessing #start' do
              expect_any_instance_of(OutboundEventProcessing).
                to receive(:start)

              event_registration.update(update_params)
            end
          end
        end
      end

      context 'when calendar is not changed' do
        context 'when registrant has outbound events configured' do
          include_context 'configure outbound_event_config' do
            let(:google_calendar) { registrant_google_calendar }
          end

          it 'starts outbound event update processing' do
            expect_any_instance_of(OutboundEventProcessing).
              to receive(:update)

            event_registration.update(update_params)
          end
        end

        context 'when registrant has allowed access to their google calendar' do
          include_context 'allow access to google calendar'

          it 'calls GoogleEventUpdater worker for registrant' do

            event_registration.update(update_params)

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
