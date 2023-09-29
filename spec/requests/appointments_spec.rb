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
        expect(response.content_type).to eq('application/json; charset=utf-8') # Modify this line
        expect(JSON.parse response.body).to eq({
          "errors" => ["Type is unrecognized"]
        })
      end
    end
  end

end
