class TimepickerInput < SimpleForm::Inputs::StringInput
  def input_html_classes
    super.push('form-control')
  end

  def input_html_options
    base_value = object.public_send(attribute_name).presence
    value = if base_value.respond_to?(:strftime)
      I18n.l(base_value, format: '%H:%M')
    else
      base_value
    end

    {
      data: { provide: 'timepicker' },
      value: value,
      type: 'text'
    }.deep_merge(super)
  end
end
