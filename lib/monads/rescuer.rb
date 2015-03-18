require 'monads/monad'

module Monads
  Rescuer = Struct.new(:value, :exception) do
    include Monad

    def and_then(&block)
      block = ensure_monadic_result(&block)

      if exception.nil?
        block.call(value)
      else
        self
      end
    end

    def self.from_value(value)
      Rescuer.new(value)
    end
  end
end
