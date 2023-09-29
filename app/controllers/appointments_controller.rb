class AppointmentsController < ApplicationController
  def index
  end

  def create
    appointment = Appointment.new(appointment_params)
    if appointment.save
      render json: appointment, status: :created
    else
      render json: { errors: appointment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def schedule
    date = Date.parse(params[:date])
    appointments = Appointment.where(starts_at: date.beginning_of_day..date.end_of_day)
    render json: appointments, status: :ok
  rescue Date::Error
    render json: { errors: ['Invalid date'] }, status: :unprocessable_entity
  end

  private

  def appointment_params
    params.require(:appointment).permit(:starts_at, :type, :patient_name)
  end
end
