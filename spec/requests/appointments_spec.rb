require 'rails_helper'

RSpec.describe "Appointments", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/appointments"
      expect(response).to have_http_status(:success)
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

        get "/schedule?date=#{valid_date}", headers: { 'ACCEPT' => 'application/json' }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json; charset=utf-8')

        json_body = JSON.parse response.body
        expect(json_body.size).to eq(3)
        expect(json_body.map { |a| a['type'] }).to eq(%w[initial standard checkin])
      end
    end

    context 'with an invalid data parameter' do
      it 'returns an invalid date error' do
        get "/schedule?date=invalid_date", headers: { 'ACCEPT' => 'application/json' }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(JSON.parse response.body).to eq({
          "errors" => ["Invalid date"]
        })

      end
    end
  end

end
