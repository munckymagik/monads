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

    def self.from_value(value)
      Rescuer.new(value)
    end
  end
end
