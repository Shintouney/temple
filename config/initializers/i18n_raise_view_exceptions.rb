# # Due to https://github.com/rails/rails/commit/ec16ba75a5493b9da972eea08bae630eba35b62f
# # Rails does not raise exceptions in views when the translation is missing
# # so they are not displayed in the test environment.
# # See https://github.com/rails/rails/pull/13183
# #
# # The helper is also changed to always raise when in "test" environment.
# unless Rails.version == '4.0.2'
#   Rails.logger.error "Obsolete monkey patch in config/initializers/fix_rails_3216_i18n_view_exceptions.rb"
# end

# module ActionView
#   module Helpers
#     module TranslationHelper
#       def translate(key, options = {})
#         options[:default] = wrap_translate_defaults(options[:default]) if options[:default]

#         if options.key?(:raise) || options.key?(:rescue_format)
#           raise_error = options[:raise] || options[:rescue_format]
#         else
#           raise_error = Rails.env.test? # PATCH
#           options[:raise] = true
#         end

#         if html_safe_translation_key?(key)
#           html_safe_options = options.dup
#           options.except(*I18n::RESERVED_KEYS).each do |name, value|
#             unless name == :count && value.is_a?(Numeric)
#               html_safe_options[name] = ERB::Util.html_escape(value.to_s)
#             end
#           end
#           translation = I18n.translate(scope_key_by_partial(key), html_safe_options)

#           translation.respond_to?(:html_safe) ? translation.html_safe : translation
#         else
#           I18n.translate(scope_key_by_partial(key), options)
#         end
#       rescue I18n::MissingTranslationData => e
#         raise e if raise_error

#         keys = I18n.normalize_keys(e.locale, e.key, e.options[:scope])
#         content_tag('span', keys.last.to_s.titleize, :class => 'translation_missing', :title => "translation missing: #{keys.join('.')}")
#       end

#       alias :t :translate
#     end
#   end
# end
