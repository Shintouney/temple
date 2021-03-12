module Admin
  module ExportsHelper
    def export_of(subtype)
      my_export = @current_exports.where(subtype: subtype)
      return nil if my_export.nil?
      my_export.first
    end
  end
end
