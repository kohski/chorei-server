# frozen_string_literal: true

def response_formatter(status, message, data)
  {
    'application/json' => {
      status: status,
      message: message,
      data: data
    }
  }
end
