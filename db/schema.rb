# frozen_string_literal: true

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

ActiveRecord::Schema.define(version: 20_190_623_051_828) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'assigns', force: :cascade do |t|
    t.integer 'member_id', null: false
    t.integer 'job_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'groups', force: :cascade do |t|
    t.string 'name', null: false
    t.text 'image'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'jobs', force: :cascade do |t|
    t.integer 'group_id', null: false
    t.string 'title', null: false
    t.text 'description'
    t.text 'image'
    t.boolean 'is_public', default: false, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'frequency', default: 0
    t.integer 'repeat_times', default: 0
    t.datetime 'base_start_at'
    t.datetime 'base_end_at'
  end

  create_table 'members', force: :cascade do |t|
    t.integer 'group_id', null: false
    t.integer 'user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.boolean 'is_owner', default: false
  end

  create_table 'schedules', force: :cascade do |t|
    t.integer 'job_id', null: false
    t.boolean 'is_done', default: false, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.datetime 'start_at', null: false
    t.datetime 'end_at', null: false
  end

  create_table 'steps', force: :cascade do |t|
    t.integer 'job_id', null: false
    t.text 'memo'
    t.text 'image'
    t.integer 'order', null: false
    t.boolean 'is_done', default: false, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'stocks', force: :cascade do |t|
    t.integer 'user_id', null: false
    t.integer 'job_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'taggings', force: :cascade do |t|
    t.integer 'job_id', null: false
    t.integer 'tag_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'tags', force: :cascade do |t|
    t.string 'name', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.integer 'group_id', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string 'provider', default: 'email', null: false
    t.string 'uid', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.boolean 'allow_password_change', default: false
    t.datetime 'remember_created_at'
    t.string 'name'
    t.text 'image'
    t.string 'email'
    t.text 'description'
    t.integer 'role', default: 0
    t.json 'tokens'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
    t.index %w[uid provider], name: 'index_users_on_uid_and_provider', unique: true
  end
end
