# frozen_string_literal: true

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  def response_success(obj)
    render(
      status: 200,
      json: {
        status: 200,
        message: "Success: #{obj == '' ? '' : obj.class}",
        data: obj
      }
    )
  end

  def response_created(obj)
    render(
      status: 201,
      json: {
        status: 201,
        message: "Created: #{obj.class}",
        data: obj
      }
    )
  end

  def response_bad_request(obj)
    render(
      status: 400,
      json: {
        status: 400,
        message: 'Bad Request',
        data: obj.nil? ? obj : obj.errors.full_messages
      }
    )
  end

  def response_not_found(text)
    render(
      status: 404,
      json: {
        status: 404,
        message: "#{text} is Not Found"
      }
    )
  end
end
