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

ActiveRecord::Schema.define(version: 20160203182550) do

  create_table "datapoints", force: :cascade do |t|
    t.integer  "Run_ID"
    t.string   "Var_Name"
    t.string   "Var_Metric"
    t.float    "Var_Value"
    t.string   "Submitter"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "Time_Taken"
    t.string   "Notes"
    t.integer  "Hrs_Post_Start"
  end

  create_table "runs", force: :cascade do |t|
    t.string   "Reactor_Type"
    t.integer  "Reactor_ID"
    t.string   "Scientist"
    t.datetime "Actual_start_date"
    t.datetime "Actual_end_date"
    t.string   "Media"
    t.float    "pH"
    t.float    "Light_Intensity"
    t.float    "Light_Path"
    t.integer  "Temperature"
    t.string   "Organism"
    t.integer  "Strain_ID"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.float    "CO2_Flow"
    t.float    "Air_Flow"
    t.float    "Depth"
    t.float    "Start_OD"
    t.integer  "Parent_Run"
    t.integer  "Day_Harvested"
    t.string   "Media_ID"
  end

end
