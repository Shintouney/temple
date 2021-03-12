class DatepickerInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    [
      @builder.text_field(attribute_name, merged_input_options),
      @builder.hidden_field(attribute_name, alt_tag_input_html_options)
    ].join.html_safe
  end

  def input_html_classes
    super.push('form-control')
  end

  def input_html_options
    value = object.public_send(attribute_name).presence && I18n.l(object.public_send(attribute_name))

    {
      data: { provide: 'datepicker' },
      value: value
    }.deep_merge(super)
  end

  def alt_tag_input_html_options
    default_tag = ActionView::Helpers::Tags::TextField.new(@builder.object_name, attribute_name, @builder)

    {
      class: "#{attribute_name}-alt",
      id: "#{default_tag.send(:tag_id)}_datepicker"
    }
  end
end
