# frozen_string_literal: true

module ForemanNetbox
  class NetboxFacet < ApplicationRecord
    include Facets::Base

    validates :host, presence: true, allow_blank: false
    validates :url, uniqueness: true

    def synchronization_success?
      !synchronization_error
    end
  end
end