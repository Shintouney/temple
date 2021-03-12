# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20191022092752) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "groups", force: :cascade do |t|
    t.string   "name",                      :limit=>255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "filter_between_age",        :limit=>255
    t.string   "filter_gender",             :limit=>255
    t.string   "filter_postal_code",        :limit=>255
    t.string   "filter_with_subscription",  :limit=>255
    t.string   "filter_created_since",      :limit=>255
    t.string   "filter_usual_room",         :limit=>255
    t.string   "filter_usual_activity",     :limit=>255
    t.string   "filter_frequencies",        :limit=>255
    t.string   "filter_last_booking_dates", :limit=>255
    t.string   "filter_last_visite_dates",  :limit=>255
    t.string   "filter_last_article",       :limit=>255
  end

  create_table "announces", force: :cascade do |t|
    t.text     "content"
    t.date     "start_at"
    t.date     "end_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name",    :limit=>255
    t.string   "file_content_type", :limit=>255
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.string   "target_link",       :limit=>255
    t.boolean  "external_link",     :default=>false
    t.boolean  "active"
    t.string   "place",             :limit=>255, :default=>"all"
    t.integer  "group_id",          :index=>{:name=>"fk__announces_group_id"}, :foreign_key=>{:references=>"groups", :name=>"fk_announces_group_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "article_categories", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       :limit=>255, :null=>false
  end

  create_table "articles", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "article_category_id"
    t.decimal  "price_ati",           :precision=>8, :scale=>2, :null=>false
    t.decimal  "price_te",            :precision=>8, :scale=>2, :null=>false
    t.decimal  "taxes_rate",          :precision=>5, :scale=>2, :null=>false
    t.string   "name",                :limit=>255, :null=>false
    t.text     "description"
    t.string   "image_file_name",     :limit=>255
    t.string   "image_content_type",  :limit=>255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.boolean  "visible",             :default=>true, :null=>false, :index=>{:name=>"index_articles_on_visible"}
  end

  create_table "card_scans", force: :cascade do |t|
    t.integer  "user_id",        :index=>{:name=>"index_card_scans_on_user_id"}
    t.string   "card_reference", :limit=>255, :null=>false
    t.datetime "scanned_at",     :null=>false
    t.integer  "scan_point",     :null=>false
    t.boolean  "accepted",       :null=>false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location",       :limit=>255
  end

  create_table "credit_cards", force: :cascade do |t|
    t.integer  "user_id",          :null=>false
    t.string   "firstname",        :limit=>255, :null=>false
    t.string   "lastname",         :limit=>255, :null=>false
    t.string   "number",           :limit=>255, :null=>false
    t.string   "cvv",              :limit=>255, :null=>false
    t.integer  "expiration_month", :null=>false
    t.integer  "expiration_year",  :null=>false
    t.string   "brand",            :limit=>255, :null=>false
    t.string   "paybox_reference", :limit=>255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exports", force: :cascade do |t|
    t.string   "state",       :limit=>255, :default=>"in_progress", :null=>false, :index=>{:name=>"index_exports_on_state"}
    t.string   "export_type", :limit=>255
    t.string   "subtype",     :limit=>255
    t.date     "date_start"
    t.date     "date_end"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                           :limit=>255, :null=>false, :index=>{:name=>"index_users_on_email", :unique=>true}
    t.string   "crypted_password",                :limit=>255
    t.string   "salt",                            :limit=>255
    t.string   "remember_me_token",               :limit=>255, :index=>{:name=>"index_users_on_remember_me_token"}
    t.datetime "remember_me_token_expires_at"
    t.string   "reset_password_token",            :limit=>255, :index=>{:name=>"index_users_on_reset_password_token"}
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.datetime "last_login_at"
    t.datetime "last_logout_at",                  :index=>{:name=>"index_users_on_last_logout_at_and_last_activity_at", :with=>["last_activity_at"]}
    t.datetime "last_activity_at"
    t.string   "last_login_from_ip_address",      :limit=>255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "role",                            :null=>false, :index=>{:name=>"index_users_on_role"}
    t.string   "firstname",                       :limit=>255, :index=>{:name=>"users_on_lower_firstname", :case_sensitive=>false}
    t.string   "lastname",                        :limit=>255, :index=>{:name=>"users_on_lower_lastname", :case_sensitive=>false}
    t.string   "street1",                         :limit=>255
    t.string   "street2",                         :limit=>255
    t.string   "postal_code",                     :limit=>255
    t.string   "city",                            :limit=>255
    t.string   "phone",                           :limit=>255
    t.date     "birthdate"
    t.string   "gender",                          :limit=>255
    t.string   "paybox_user_reference",           :limit=>255
    t.integer  "profile_user_image_id"
    t.integer  "current_credit_card_id"
    t.string   "card_reference",                  :limit=>255
    t.integer  "sponsor_id"
    t.string   "facebook_url",                    :limit=>255
    t.string   "linkedin_url",                    :limit=>255
    t.string   "professional_sector",             :limit=>255
    t.string   "position",                        :limit=>255
    t.string   "company",                         :limit=>255
    t.string   "professional_address",            :limit=>255
    t.string   "education",                       :limit=>255
    t.string   "heard_about_temple_from",         :limit=>255
    t.string   "professional_zipcode",            :limit=>255
    t.string   "professional_city",               :limit=>255
    t.integer  "card_access"
    t.integer  "current_deferred_invoice_id"
    t.boolean  "receive_mail_ical",               :default=>true, :null=>false
    t.boolean  "force_access_to_planning",        :default=>false, :null=>false
    t.boolean  "forbid_access_to_planning",       :default=>false
    t.string   "payment_mode",                    :limit=>255, :default=>"none"
    t.string   "billing_name",                    :limit=>255
    t.boolean  "receive_booking_confirmation",    :default=>true, :null=>false
    t.string   "country_code",                    :limit=>255, :default=>"fr", :null=>false
    t.string   "location",                        :limit=>255
    t.string   "billing_address",                 :limit=>255
    t.datetime "deactivated_at",                  :index=>{:name=>"index_users_on_deactivated_at"}
  end
  add_index "users", ["deactivated_at", "role"], :name=>"index_users_on_deactivated_at_and_role"

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "user_id",  :index=>{:name=>"index_groups_users_on_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_groups_users_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer "group_id", :index=>{:name=>"index_groups_users_on_group_id"}, :foreign_key=>{:references=>"groups", :name=>"fk_groups_users_group_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "invoices", force: :cascade do |t|
    t.date     "start_at"
    t.date     "end_at",                       :index=>{:name=>"index_invoices_on_end_at"}
    t.date     "subscription_period_start_at"
    t.date     "subscription_period_end_at"
    t.date     "next_payment_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "user_firstname",               :limit=>255
    t.string   "user_lastname",                :limit=>255
    t.string   "user_street1",                 :limit=>255
    t.string   "user_street2",                 :limit=>255
    t.string   "user_postal_code",             :limit=>255
    t.string   "user_city",                    :limit=>255
    t.decimal  "total_price_ati",              :precision=>8, :scale=>2, :default=>0.0, :null=>false
    t.string   "state",                        :default=>"open", :null=>false, :index=>{:name=>"index_invoices_on_state"}
    t.datetime "refunded_at"
    t.datetime "canceled_at"
    t.boolean  "manual_force_paid",            :default=>false, :null=>false
    t.string   "billing_name",                 :limit=>255
    t.integer  "credit_note_ref"
    t.string   "billing_address",              :limit=>255
  end

  create_table "invoices_payments", force: :cascade do |t|
    t.integer "invoice_id", :index=>{:name=>"index_invoices_payments_on_invoice_id"}
    t.integer "payment_id", :index=>{:name=>"index_invoices_payments_on_payment_id"}
  end

  create_table "lesson_bookings", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lesson_id",  :null=>false
    t.integer  "user_id",    :null=>false, :index=>{:name=>"index_lesson_bookings_on_user_id_and_lesson_id", :with=>["lesson_id"], :unique=>true}
  end

  create_table "lesson_drafts", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "room",          :limit=>255
    t.string   "coach_name",    :limit=>255
    t.string   "activity",      :limit=>255
    t.time     "start_at_hour", :null=>false
    t.time     "end_at_hour",   :null=>false
    t.integer  "weekday",       :null=>false
    t.integer  "max_spots"
    t.string   "location",      :limit=>255, :default=>"moliere", :null=>false, :index=>{:name=>"index_lesson_drafts_on_location"}
  end

  create_table "lesson_requests", force: :cascade do |t|
    t.string   "first_coach_name",  :limit=>255
    t.string   "second_coach_name", :limit=>255
    t.text     "comment"
    t.integer  "user_id",           :index=>{:name=>"fk__lesson_requests_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_lesson_requests_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lesson_templates", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "room",          :limit=>255
    t.string   "coach_name",    :limit=>255
    t.string   "activity",      :limit=>255
    t.integer  "weekday",       :null=>false
    t.time     "start_at_hour", :null=>false
    t.integer  "max_spots"
    t.time     "end_at_hour",   :null=>false
    t.string   "location",      :limit=>255, :default=>"moliere", :null=>false, :index=>{:name=>"index_lesson_templates_on_location"}
  end

  create_table "lessons", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lesson_template_id"
    t.string   "room",               :limit=>255
    t.string   "coach_name",         :limit=>255
    t.string   "activity",           :limit=>255
    t.datetime "start_at"
    t.datetime "end_at"
    t.boolean  "cancelled",          :default=>false
    t.integer  "max_spots"
    t.integer  "lesson_draft_id",    :index=>{:name=>"fk__lessons_lesson_draft_id"}, :foreign_key=>{:references=>"lesson_drafts", :name=>"fk_lessons_lesson_draft_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "location",           :limit=>255, :default=>"moliere", :null=>false, :index=>{:name=>"index_lessons_on_location"}
  end

  create_table "mandates", force: :cascade do |t|
    t.integer  "user_id",                 :index=>{:name=>"fk__mandates_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_mandates_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.string   "slimpay_rum",             :limit=>255
    t.string   "slimpay_state",           :limit=>255
    t.datetime "slimpay_created_at"
    t.datetime "slimpay_revoked_at"
    t.string   "slimpay_approval_url",    :limit=>255
    t.string   "slimpay_order_reference", :limit=>255
    t.string   "slimpay_order_state",     :limit=>255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "marked_as_deleted",       :default=>false, :null=>false
  end

  create_table "notification_schedules", force: :cascade do |t|
    t.datetime "scheduled_at"
    t.integer  "user_id",      :index=>{:name=>"index_notification_schedules_on_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_notification_schedules_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "lesson_id",    :index=>{:name=>"index_notification_schedules_on_lesson_id"}, :foreign_key=>{:references=>"lessons", :name=>"fk_notification_schedules_lesson_id", :on_update=>:no_action, :on_delete=>:no_action}
  end

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",         :index=>{:name=>"fk__notifications_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_notifications_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.integer  "sourceable_id",   :index=>{:name=>"index_notifications_on_sourceable_id_and_sourceable_type", :with=>["sourceable_type"]}
    t.string   "sourceable_type", :limit=>255
    t.datetime "created_at",      :null=>false
    t.datetime "updated_at",      :null=>false
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id",              :null=>false
    t.string   "product_type",          :limit=>255, :null=>false
    t.integer  "product_id",            :null=>false
    t.string   "product_name",          :limit=>255, :null=>false
    t.decimal  "product_price_ati",     :precision=>8, :scale=>2, :null=>false
    t.decimal  "product_price_te",      :precision=>8, :scale=>2, :null=>false
    t.decimal  "product_taxes_rate",    :precision=>5, :scale=>2, :null=>false
    t.string   "product_category_name", :limit=>255
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "invoice_id"
    t.string   "location",   :limit=>255
  end

  create_table "payments", force: :cascade do |t|
    t.datetime "created_at",              :index=>{:name=>"index_payments_on_created_at"}
    t.datetime "updated_at"
    t.integer  "user_id",                 :null=>false
    t.decimal  "price",                   :precision=>8, :scale=>2, :default=>0.0, :null=>false
    t.string   "paybox_transaction",      :limit=>255
    t.string   "state",                   :default=>"transaction_pending", :null=>false, :index=>{:name=>"index_payments_on_state"}
    t.integer  "credit_card_id"
    t.string   "comment",                 :limit=>255, :index=>{:name=>"index_payments_on_comment"}
    t.string   "slimpay_direct_debit_id", :limit=>255
    t.string   "slimpay_status",          :limit=>255
  end

  create_table "profiles", force: :cascade do |t|
    t.string  "sports_practiced",             :limit=>255
    t.string  "attendance_rate",              :limit=>255
    t.string  "fitness_goals",                :limit=>255
    t.string  "boxing_disciplines_practiced", :limit=>255
    t.string  "boxing_level",                 :limit=>255
    t.string  "boxing_disciplines_wished",    :limit=>255
    t.string  "attendance_periods",           :limit=>255
    t.string  "weekdays_attendance_hours",    :limit=>255
    t.string  "weekend_attendance_hours",     :limit=>255
    t.string  "transportation_means",         :limit=>255
    t.integer "user_id",                      :null=>false
  end

  create_table "rtransactions", force: :cascade do |t|
    t.string   "file_name",  :limit=>255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sponsoring_requests", force: :cascade do |t|
    t.string   "firstname",  :limit=>255
    t.string   "lastname",   :limit=>255
    t.string   "phone",      :limit=>255
    t.string   "email",      :limit=>255
    t.integer  "user_id",    :index=>{:name=>"fk__sponsoring_requests_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_sponsoring_requests_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscription_plans", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "price_ati",             :precision=>8, :scale=>2, :null=>false
    t.string   "name",                  :limit=>255, :null=>false
    t.text     "description"
    t.decimal  "price_te",              :precision=>8, :scale=>2, :null=>false
    t.decimal  "taxes_rate",            :precision=>5, :scale=>2, :null=>false
    t.integer  "commitment_period",     :default=>0, :null=>false
    t.string   "code",                  :limit=>255
    t.integer  "discount_period",       :default=>0, :null=>false
    t.decimal  "discounted_price_te",   :precision=>8, :scale=>2
    t.decimal  "discounted_price_ati",  :precision=>8, :scale=>2
    t.boolean  "displayable",           :default=>false, :null=>false
    t.boolean  "favorite",              :default=>false, :null=>false
    t.integer  "position"
    t.datetime "expire_at"
    t.decimal  "sponsorship_price_te",  :precision=>8, :scale=>2
    t.decimal  "sponsorship_price_ati", :precision=>8, :scale=>2
    t.string   "locations",             :limit=>255
    t.boolean  "disabled",              :default=>false, :null=>false
  end

  create_table "subscriptions", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                :null=>false
    t.integer  "subscription_plan_id",   :null=>false
    t.string   "state",                  :default=>"pending", :null=>false, :index=>{:name=>"index_subscriptions_on_state"}
    t.date     "start_at",               :index=>{:name=>"index_subscriptions_on_start_at"}
    t.date     "end_at"
    t.date     "next_payment_at"
    t.integer  "discount_period",        :default=>0
    t.integer  "commitment_period",      :default=>0, :null=>false
    t.date     "restart_date"
    t.date     "suspended_at"
    t.date     "end_of_commitment_date"
    t.integer  "grace_period_in_days"
    t.string   "locations",              :limit=>255
    t.string   "origin_location",        :limit=>255
    t.date     "replaced_date"
  end

  create_table "suspended_subscription_schedules", force: :cascade do |t|
    t.integer  "user_id",                   :index=>{:name=>"fk__suspended_subscription_schedules_user_id"}, :foreign_key=>{:references=>"users", :name=>"fk_suspended_subscription_schedules_user_id", :on_update=>:no_action, :on_delete=>:no_action}
    t.datetime "scheduled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "subscription_restart_date"
  end

  create_table "unsubscribe_requests", force: :cascade do |t|
    t.string   "firstname",     :limit=>255
    t.string   "lastname",      :limit=>255
    t.string   "phone",         :limit=>255
    t.string   "email",         :limit=>255
    t.date     "desired_date"
    t.boolean  "health_reason"
    t.boolean  "moving_reason"
    t.string   "other_reason",  :limit=>255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_images", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",            :null=>false
    t.string   "image_file_name",    :limit=>255
    t.string   "image_content_type", :limit=>255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "visits", force: :cascade do |t|
    t.integer  "user_id",          :index=>{:name=>"index_visits_on_user_id"}
    t.datetime "started_at"
    t.datetime "ended_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "checkin_scan_id"
    t.integer  "checkout_scan_id"
    t.string   "location",         :limit=>255
  end

end
