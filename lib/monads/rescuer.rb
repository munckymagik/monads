require 'monads/monad'

module Monads
  Rescuer = Struct.new(:value, :exception) do
    include Monad

    def and_then(&block)
      if exception.nil?
        begin
          block = ensure_monadic_result(&block)
          block.call(value)
        rescue => exc
          raise if exc.is_a? MonadicResultTypeError
          Rescuer.new(nil, exc)
        end
      else
        self
      end
    end

    def self.from_value(value = nil, &block)
      if block.nil?
        Rescuer.new(value)
      else
        begin
          Rescuer.new(block.call)
        rescue => exc
          Rescuer.new(nil, exc)
        end
      end
    end
  end
end
