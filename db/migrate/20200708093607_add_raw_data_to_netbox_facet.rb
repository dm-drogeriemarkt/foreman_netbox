# frozen_string_literal: true

class AddRawDataToNetboxFacet < ActiveRecord::Migration[5.2]
  def change
    add_column :netbox_facets, :raw_data, :jsonb, default: {}
  end
end
