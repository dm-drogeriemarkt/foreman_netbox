# frozen_string_literal: true

class AddSyncInfoToNetboxFacet < ActiveRecord::Migration[5.2]
  def change
    add_column :netbox_facets, :synchronized_at, :datetime
    add_column :netbox_facets, :synchronization_error, :string
  end
end
