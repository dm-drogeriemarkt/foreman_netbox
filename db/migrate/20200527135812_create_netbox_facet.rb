# frozen_string_literal: true

class CreateNetboxFacet < ActiveRecord::Migration[5.2]
  def change
    create_table :netbox_facets do |t|
      t.references :host, null: false, foreign_key: true, index: true, unique: true
      t.string :url, unique: true

      t.timestamps null: false
    end
  end
end
