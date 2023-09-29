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

  private

  def appointment_params
    params.require(:appointment).permit(:starts_at, :type, :patient_name)
  end
end
