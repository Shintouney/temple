# WickedPDF Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the `render :pdf` call.
#
# To learn more, check out the README:
#
# https://github.com/mileszs/wicked_pdf/blob/master/README.md

WickedPdf.config = {
  # Path to the wkhtmltopdf executable: This usually isn't needed if using
  # one of the wkhtmltopdf-binary family of gems.
  # exe_path: '/usr/local/bin/wkhtmltopdf',
  #   or
  exe_path: Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf'),

  # Layout file to be used for all PDFs
  # (but can be overridden in `render :pdf` calls)
  # layout: 'pdf.html',
  layout: 'application',

  use_xserver: false,
  page_size: "A4",
  margin:{ top: '10mm', bottom: '10mm', left: '10mm', right: '10mm'},
  footer: { center: "SAS Pugil Invest, 9 rue Molière, 75001 Paris\r\n TVA intracommunautaire : FR8580051790600015", right: "[page] / [topage]", font_size: '8', spacing: '0', line: false }
}
