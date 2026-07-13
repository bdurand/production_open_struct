# frozen_string_literal: true

require "ostruct"

# Overrides OpenStruct behavior to no longer define singleton methods on each object.
#
# Note: unlike the standard library implementation, this code does not need to use
# the `raise!` and `block_given!` aliases. Those aliases exist to protect OpenStruct
# internals from fields that shadow built in methods via singleton methods. Since this
# module prevents singleton methods from ever being defined, built in methods can no
# longer be shadowed. The aliases also don't exist in the ostruct versions bundled
# with Ruby <= 3.0 or on JRuby, so using them would break on those platforms.
module ProductionOpenStruct
  # @param name [Symbol, String] the name of the field to delete
  # @return [void]
  def delete_field(name, &block)
    raise FrozenError, "can't modify frozen #{self.class}: #{inspect}" if frozen?

    sym = name.to_sym
    begin
      # Clean up stale accessors on objects created before this module was prepended.
      singleton_class.remove_method(sym, "#{sym}=")
    rescue NameError
    end
    @table.delete(sym) do
      return yield if block
      raise NameError.new("no field `#{sym}' in #{self}", sym)
    end
  end

  private

  def new_ostruct_member!(name)
    # no-op to avoid defining singleton methods that will bust the method cache.
    name.to_sym
  end

  def method_missing(method_name, *args) # :nodoc:
    len = args.length
    if method_name.to_s.end_with?("=")
      if len != 1
        raise ArgumentError, "wrong number of arguments (given #{len}, expected 1)", caller(1)
      end
      self[method_name.to_s.chomp("=")] = args[0]
    elsif len == 0
      @table[method_name]
    else
      begin
        super
      rescue NoMethodError => err
        err.backtrace.shift
        raise
      end
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    key = method_name.to_s.chomp("=").to_sym
    (defined?(@table) && @table.include?(key)) || super
  end
end

OpenStruct.prepend(ProductionOpenStruct) unless ENV["PRODUCTION_OPEN_STRUCT_AUTO_INCLUDE"] == "false"
