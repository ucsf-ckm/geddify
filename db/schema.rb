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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120419213804) do

  create_table "accesshistories", :force => true do |t|
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gedifilename_id"
  end

  create_table "gedifilenames", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gedifile_id"
    t.string   "status"
    t.string   "auth_token"
    t.date     "auth_token_timestamp"
  end

  create_table "gedifiles", :force => true do |t|
    t.string   "IFID"
    t.string   "IFVR"
    t.string   "CILN"
    t.string   "DFID"
    t.string   "SSAD"
    t.string   "CNSN"
    t.string   "RCNM"
    t.string   "SPLN"
    t.string   "SVDT"
    t.string   "SYID"
    t.string   "SYAD"
    t.string   "DLVS"
    t.string   "CNFA"
    t.string   "PRTY"
    t.string   "GNLN"
    t.string   "CLNT"
    t.string   "CLID"
    t.string   "CLST"
    t.string   "NPOI"
    t.string   "XPDA"
    t.string   "STNM"
    t.string   "POBX"
    t.string   "CITY"
    t.string   "REGN"
    t.string   "CNTR"
    t.string   "POCD"
    t.string   "RQID"
    t.string   "RQNM"
    t.string   "RSID"
    t.string   "RSNM"
    t.string   "CPRT"
    t.string   "ILTI"
    t.string   "RSNT"
    t.string   "RCON"
    t.string   "ATHR"
    t.string   "TTLE"
    t.string   "VLIS"
    t.string   "AART"
    t.string   "TART"
    t.string   "ISBN"
    t.string   "ISSN"
    t.string   "BBLD"
    t.string   "PGNS"
    t.string   "DTSC"
    t.string   "NMPG"
    t.string   "CLNO"
    t.string   "PDOC"
    t.string   "PUBD"
    t.string   "PLPB"
    t.string   "PUBL"
    t.string   "EDIT"
    t.string   "RQAQ"
    t.string   "STAT"
    t.string   "ITID"
    t.string   "ZPAD"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "lock_version", :default => 0, :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

end
