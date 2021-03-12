module ApplicationHelper
  include Pagy::Frontend

  # Public: Build a title String to display in the HTML title tag.
  # Use content_for(:page_title, "Content") to set the title text,
  # or define a translation for the page_title or title key in the rendered view scope.
  #
  # Returns a String.
  def page_title
    layout = controller.send(:_layout)
    base_title = I18n.t("layouts.#{layout}.title", default: :'layouts.application.title')

    i18n_scope = "#{params[:controller].gsub('/', '.')}.#{action_name}"
    i18n_parts = [
      content_for(:page_title),
      I18n.t(:page_title, default: "", scope: i18n_scope).presence,
      I18n.t(:title, default: "", scope: i18n_scope).presence
    ]
    title_content = i18n_parts.compact.first
    [base_title, title_content].compact.join(' - ')
  end

  # Public: Build Bootstrap-styled HTML
  # from flash messages.
  #
  # Returns the generated HTML as a String.
  def flash_content(flash)
    content_tag :div, id: 'flash' do
      {alert: 'alert alert-warning', notice: 'alert alert-info'}.map do |flash_key, css_classes|
        if flash[flash_key]
          content_tag :div, flash[flash_key].html_safe, class: css_classes
        end
      end.compact.join('').html_safe
    end
  end

  # Public: An options Array for choosing a credit card brand.
  #
  # Returns an Array usable in an options helper.
  def credit_card_brand_options
    SUPPORTED_CARDTYPES.map { |brand| [I18n.t(brand, scope: 'activemerchant.credit_card.brand'), brand] }
  end

  # Public: Display a boolean as an icon.
  #
  # value - The Boolean value to display.
  #
  # Returns an HTML String.
  def boolean_icon(value)
    css_classes = ['fa', 'fa-lg']

    if value
      css_classes << 'fa-check-circle text-success'
    else
      css_classes << 'fa-times-circle text-danger'
    end

    content_tag(:em, class: css_classes.join(' ')) do
      content_tag(:span, value.to_s, class: 'sr-only')
    end
  end

  # Public: Display an asset as a base64-encoded String.
  # To be used inside PDF views rendered via wicked_pdf.
  # See https://github.com/mileszs/wicked_pdf/issues/257 for more details.
  #
  # path - The asset path.
  #
  # Returns a String.
  def asset_data_base64(logical_file_path)
    asset = (Rails.application.assets || ::Sprockets::Railtie.build_environment(Rails.application)).find_asset(logical_file_path)
    throw "Could not find asset '#{logical_file_path}'" if asset.nil?
    base64 = Base64.encode64(asset.to_s).gsub(/\s+/, "")
    "data:#{asset.content_type};base64,#{Rack::Utils.escape(base64)}"
  end

  # tel_to '+1 (0)555 123-456'
  # tel_to '+1 555 123-456'
  # tel_to '(01234) 555 6789'
  def tel_to(text)
    groups = text.to_s.scan(/(?:^\+)?\d+/)
    if groups.size > 1 && groups[0][0] == '+'
      # remove leading 0 in area code if this is an international number
      groups[1] = groups[1][1..-1] if groups[1][0] == '0'
      groups.delete_at(1) if groups[1].size == 0 # remove if it was only a 0
    end
    link_to text, "tel:#{groups.join '-'}"
  end

  def display_results(unmatched_entries)
    if unmatched_entries.size == 0
      $stdout.puts "\e[32m0\e[0m error."
    else
      $stdout.puts "\e[31m#{unmatched_entries.size} errors\e[0m."
    end
  end
end
