require 'rails_helper'

RSpec.describe "Appointments", type: :request do
  describe "GET /appointments" do
    context 'with empty schedule' do
      it 'returns 14 available initial appointments' do
        get "/appointments?date=2023-09-30&type=initial"
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_body = JSON.parse response.body
        expect(json_body.size).to eq(14)
        expect(json_body.first['starts_at']).to eq('2023-09-30T09:00:00.000Z')
        expect(json_body.last['starts_at']).to eq('2023-09-30T15:30:00.000Z')
      end

      it 'returns 15 available standard appointments' do
        get "/appointments?date=2023-09-30&type=standard"
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_body = JSON.parse response.body
        expect(json_body.size).to eq(15)
        expect(json_body.first['starts_at']).to eq('2023-09-30T09:00:00.000Z')
        expect(json_body.last['starts_at']).to eq('2023-09-30T16:00:00.000Z')
      end

      it 'returns 16 available checkin appointments' do
        get "/appointments?date=2023-09-30&type=checkin"
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_body = JSON.parse response.body
        expect(json_body.size).to eq(16)
        expect(json_body.first['starts_at']).to eq('2023-09-30T09:00:00.000Z')
        expect(json_body.last['starts_at']).to eq('2023-09-30T16:30:00.000Z')
      end

      it 'does not return appointments within 2 hours' do
        travel_to Time.parse('2023-09-30 09:00 UTC') do
          get "/appointments?date=2023-09-30&type=checkin"
          expect(response).to have_http_status(:success)
          expect(response.content_type).to eq('application/json; charset=utf-8')
          json_body = JSON.parse response.body
          expect(json_body.size).to eq(12)
          expect(json_body.first['starts_at']).to eq('2023-09-30T11:00:00.000Z')
        end
      end
    end

    context 'with a full schedule' do
      it 'does not return any appointments' do
        travel_to Time.parse('2023-09-30 09:00 UTC') do
          (9..16).each do |start_hour|
            Appointment.create(starts_at: Date.today+start_hour.hours, type: :standard, patient_name: 'Alice')
          end

          get "/appointments?date=2023-09-30&type=checkin"
          expect(response).to have_http_status(:success)
          expect(response.content_type).to eq('application/json; charset=utf-8')
          json_body = JSON.parse response.body
          expect(json_body.size).to eq(0)
        end
      end
    end

    context 'with a schedule with an hour open on each end' do
      before(:each) do
        travel_to Time.parse('2023-09-30 09:00 UTC')
        (10..15.5).step(0.5).each do |start_hour|
          Appointment.create(starts_at: Date.tomorrow+start_hour.hours, type: :checkin, patient_name: 'Alice')
        end
      end

      after(:each) do
        travel_back
      end

      it 'returns 4 checkin appointments for the empty slots' do
        get "/appointments?date=2023-10-01&type=checkin"
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_body = JSON.parse response.body
        expect(json_body.size).to eq(4)
      end

      it 'returns standard appointments for the empty slots' do
        get "/appointments?date=2023-10-01&type=standard"
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_body = JSON.parse response.body
        expect(json_body.size).to eq(2)
      end

      it 'returns 0 initial appointments for the empty slots' do
        get "/appointments?date=2023-10-01&type=initial"
        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        json_body = JSON.parse response.body
        expect(json_body.size).to eq(0)
      end
    end
  end

  describe "POST /appointments" do
    context 'with valid parameters' do
      it 'creates a new appointment' do
        appointment_params = {
          appointment: {
            starts_at: '2023-09-30 10:00:00',
            type: 'initial',
            patient_name: 'Alice'
          }
        }

        expect {
          post '/appointments', params: appointment_params, as: :json
        }.to change { Appointment.count }.by(1)

        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse response.body).to include({
          "starts_at"    => "2023-09-30T10:00:00.000Z",
          "type"         => "initial",
          "patient_name" => "Alice"
        })
      end
    end

    context 'with invalid parameters' do
      it 'returns an unprocessable entity status' do
        appointment_params = {
          appointment: {
            starts_at:    '2023-09-30 10:00', 
            type:         'invalid-type',
            patient_name: 'Bob'
          }
        }

        post '/appointments', params: appointment_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse response.body).to eq({
          "errors" => ["Type is unrecognized"]
        })
      end
    end
  end

  describe 'GET /schedule' do
    context 'with a valid date parameter' do
      it 'returns appointments for the specified date in the correct order' do
        valid_date = Date.tomorrow
        Appointment.create(starts_at: valid_date+9.hours, type: :initial, patient_name: 'Alice')
        Appointment.create(starts_at: valid_date+12.hours, type: :standard, patient_name: 'Bob')
        Appointment.create(starts_at: valid_date+16.hours, type: :checkin, patient_name: 'Carol')

        get "/schedule?date=#{valid_date}"

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        json_body = JSON.parse response.body
        expect(json_body.size).to eq(3)
        expect(json_body.map { |a| a['type'] }).to eq(%w[initial standard checkin])
      end
    end

    context 'with an invalid data parameter' do
      it 'returns an invalid date error' do
        get "/schedule?date=invalid_date"

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse response.body).to eq({
          "errors" => ["Invalid date"]
        })

      end
    end
  end

end
