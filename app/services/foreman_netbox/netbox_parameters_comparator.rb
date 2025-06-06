# frozen_string_literal: true

module ForemanNetbox
  class NetboxParametersComparator
    def self.call(old_hash, new_hash)
      new(old_hash, new_hash).call
    end

    def initialize(old_hash, new_hash)
      @old_hash = old_hash
      @new_hash = new_hash
    end

    def call
      keys_diff.deep_merge(diff_old)
               .deep_merge(diff_new)
               .compact
    end

    attr_reader :old_hash, :new_hash

    private

    def added_keys
      new_hash.keys - old_hash.keys
    end

    def removed_keys
      old_hash.keys - new_hash.keys
    end

    def keys_diff
      result = {}

      result[:added] = added_keys.index_with { |key| new_hash[key] } if added_keys.any?
      if removed_keys.any?
        result[:removed] = removed_keys.index_with do |key|
          old_hash[key]
        end
      end

      result
    end

    def diff_old
      old_hash.except(*removed_keys).each_with_object({}) do |(key, old_value), memo|
        case old_value
        when Hash
          new_value = new_hash.fetch(key, {})
          diff = ForemanNetbox::NetboxParametersComparator.call(old_value, new_value)

          next unless diff.keys.any?

          memo[key] = diff
        when Array
          next if new_hash[key]

          memo[key] = { added: [], removed: old_value }
        else
          new_value = new_hash.fetch(key, nil)

          next if old_value == new_value

          memo[key] = { old: old_value, new: new_value }
        end
      end.compact
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def diff_new
      new_hash.except(*added_keys).each_with_object({}) do |(key, new_value), memo|
        case new_value
        when Hash
          old_value = old_hash.fetch(key, {})

          next if old_value == new_value

          diff = ForemanNetbox::NetboxParametersComparator.call(old_value, new_value)

          next unless diff.keys.any?

          memo[key] = diff
        when Array
          old_value = old_hash.fetch(key, [])
          added = new_value.reject { |item| old_value.find { |x| x == item } }
          removed = old_value.reject { |item| new_value.find { |x| x == item } }

          next unless added.any? || removed.any?

          memo[key] = { added: added, removed: removed }
        else
          old_value = old_hash.fetch(key, nil)

          next if old_value == new_value

          memo[key] = { old: old_value, new: new_value }
        end
      end.compact
    end
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
