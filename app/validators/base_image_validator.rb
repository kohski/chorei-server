# frozen_string_literal: true

class BaseImageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil? || value == ''
    avairable_mime_type = %w[jpeg png gif jpg]
    target_index = value.index(',')
    if target_index.nil?
      record.errors[attribute] << (options[:message] || I18n.t('errors.messages.wrong_mime_type'))
      return
    end
    target_sentence = value.slice(0, target_index)
    is_image = target_sentence.index('data:image').present?
    is_avairable_mime_type = avairable_mime_type.map do |elm|
      target_sentence.index(elm).present?
    end.any?
    is_base64 = target_sentence.index(';base64')
    record.errors[attribute] << (options[:message] || I18n.t('errors.messages.wrong_mime_type')) if [is_image, is_avairable_mime_type, is_base64].none?
  end
end
