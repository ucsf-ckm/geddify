class CreateGedifiles < ActiveRecord::Migration
  def change
    create_table :gedifiles do |t|
      t.string :IFID
      t.string :IFVR
      t.string :CILN
      t.string :DFID
      t.string :SSAD
      t.string :CNSN
      t.string :RCNM
      t.string :SPLN
      t.string :SVDT
      t.string :SYID
      t.string :SYAD
      t.string :DLVS
      t.string :CNFA
      t.string :PRTY
      t.string :GNLN
      t.string :CLNT
      t.string :CLID
      t.string :CLST
      t.string :NPOI
      t.string :XPDA
      t.string :STNM
      t.string :POBX
      t.string :CITY
      t.string :REGN
      t.string :CNTR
      t.string :POCD
      t.string :RQID
      t.string :RQNM
      t.string :RSID
      t.string :RSNM
      t.string :CPRT
      t.string :ILTI
      t.string :RSNT
      t.string :RCON
      t.string :ATHR
      t.string :TTLE
      t.string :VLIS
      t.string :AART
      t.string :TART
      t.string :ISBN
      t.string :ISSN
      t.string :BBLD
      t.string :PGNS
      t.string :DTSC
      t.string :NMPG
      t.string :CLNO
      t.string :PDOC
      t.string :PUBD
      t.string :PLPB
      t.string :PUBL
      t.string :EDIT
      t.string :RQAQ
      t.string :STAT
      t.string :ITID
      t.string :ZPAD

      t.timestamps
    end
  end
end
