class AnnounceDecorator < ApplicationDecorator
  delegate_all

  def link
    if object.target_link.start_with?('http', 'https')
      object.target_link
    else
      "http://#{object.target_link}"
    end
  end

  def target
    object.external_link? ? '_blank' : '_self'
  end

  def state
    return if object.start_at.nil? || object.end_at.nil?
    if object.end_at < Date.today
      finished_tag
    elsif object.start_at <= Date.today && object.end_at > Date.today
      launched_tag
    else
      ready_tag
    end
  end

  def active_tag
    if object.active?
      helpers.content_tag(:i,
                          class: 'fa fa-check-circle text-success',
                          'aria-label' => I18n.t(:active, scope: [:admin, :announces, :index])
                          ) { }
    else
      helpers.content_tag(:i,
                          class: 'fa fa-times-circle muted',
                          'aria-label' => I18n.t(:not_active, scope: [:admin, :announces, :index])
                          ) { }
    end
  end

  def place_tag
    place_label = case object.place
                  when 'all'
                    'default'
                  when 'dashboard'
                    'primary'
                  end
    helpers.content_tag :span, class: "label label-#{place_label}" do
      I18n.t(object.place, scope: [:admin, :announces, :index])
    end
  end

  private

  def finished_tag
    helpers.content_tag :span, class: 'label label-default' do
      I18n.t(:finished, scope: [:admin, :announces, :index, :state])
    end
  end

  def launched_tag
    helpers.content_tag :span, class: 'label label-success' do
      I18n.t(:launched, scope: [:admin, :announces, :index, :state])
    end
  end

  def ready_tag
    helpers.content_tag :span, class: 'label label-primary' do
      I18n.t(:ready, scope: [:admin, :announces, :index, :state])
    end
  end
end
