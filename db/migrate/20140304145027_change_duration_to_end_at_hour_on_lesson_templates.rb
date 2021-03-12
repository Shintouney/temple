class ChangeDurationToEndAtHourOnLessonTemplates < ActiveRecord::Migration
  def up
    add_column :lesson_templates, :end_at_hour, :time

    LessonTemplate.
      connection.
      select_all("SELECT id, start_at_hour, duration FROM lesson_templates").each do |lesson_template_attributes|

        start_at_hour = Tod::TimeOfDay.parse(lesson_template_attributes['start_at_hour'])
        end_at_hour = (start_at_hour + lesson_template_attributes['duration'].to_i.hours).to_s

        LessonTemplate.where(id: lesson_template_attributes['id']).update_all(end_at_hour: end_at_hour)
    end

    remove_column :lesson_templates, :duration
    change_column :lesson_templates, :end_at_hour, :time, null: false
  end

  def down
    add_column :lesson_templates, :duration, :integer

    LessonTemplate.
      connection.
      select_all("SELECT id, start_at_hour, end_at_hour FROM lesson_templates").each do |lesson_template_attributes|

        start_at_hour = Tod::TimeOfDay.parse(lesson_template_attributes['start_at_hour'])
        end_at_hour = Tod::TimeOfDay.parse(lesson_template_attributes['end_at_hour'])

        duration = (Shift.new(start_at_hour, end_at_hour).duration.to_f / 1.hour).round
        LessonTemplate.where(id: lesson_template_attributes['id']).update_all(duration: duration)
    end

    remove_column :lesson_templates, :end_at_hour
    change_column :lesson_templates, :duration, :integer, null: false
  end
end
