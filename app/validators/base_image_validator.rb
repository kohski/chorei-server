# frozen_string_literal: true

class BaseImageValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.nil?
    avairable_mime_type = %w[jpeg png gif]
    target_index = value.index(',')
    if target_index.nil?
      record.errors[attribute] << (options[:message] || 'のMIMEタイプが不正です')
      return
    end
    target_sentence = value.slice(0, target_index)
    is_image = target_sentence.index('data:image').present?
    is_avairable_mime_type = avairable_mime_type.map do |elm|
      target_sentence.index(elm).present?
    end.any?
    is_base64 = target_sentence.index(';base64')
    record.errors[attribute] << (options[:message] || 'のMIMEタイプが不正です') if [is_image, is_avairable_mime_type, is_base64].none?
  end
end
