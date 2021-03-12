OPEN_MODE = "w+:UTF-16LE:UTF-8"
BOM = "\xEF\xBB\xBF"
# [2017, 2018, 2019].each do |target_year|
#   File.open(Rails.root.join("tmp", "exports", "Export des réservations depuis la rentrée sur l'année #{target_year}.tsv"), OPEN_MODE) do |f|
#     csv_data = LessonBooking.to_csv({}, "#{target_year}-09-01", "#{target_year+1}-08-31")
#     f.write(BOM)
#     f.write(csv_data)
#   end
# end

File.open(Rails.root.join("tmp", "exports", "Export des réservations depuis le 01 septembre 2017.tsv"), OPEN_MODE) do |f|
  csv_data = LessonBooking.to_csv({}, "2017-09-01", "")
  f.write(BOM)
  f.write(csv_data)
end