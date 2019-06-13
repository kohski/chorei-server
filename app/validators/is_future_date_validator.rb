# frozen_string_literal: true

class IsFutureDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    end_at = record[attribute]
    return if end_at.nil?
    start_at = record[:start_at]
    record.errors[attribute] << (options[:message] || I18n.t('errors.date_custom_format', attribute_start: I18n.t('activerecord.attributes.schedule.start_at'), message: I18n.t('errors.messages.past'))) if end_at.to_f < start_at.to_f
  end
end
