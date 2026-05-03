ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Minitest 6 removed Object#stub. Re-add a compatible block-scoped implementation.
# Only Proc/lambda values are treated as callables; other objects are returned as-is.
# rescue NameError in ensure handles races when parallel tests stub the same singleton.
class Object
  def stub(method_name, val_or_callable, &block)
    aliased   = "__stub__#{method_name}"
    metaclass = class << self; self; end
    defined_on_singleton = metaclass.method_defined?(method_name, false)

    metaclass.send(:alias_method, aliased, method_name) if defined_on_singleton
    metaclass.send(:define_method, method_name) do |*args, **kwargs, &blk|
      val_or_callable.is_a?(Proc) ? val_or_callable.call(*args, **kwargs, &blk) : val_or_callable
    end

    block.call(self)
  ensure
    metaclass.send(:undef_method, method_name) rescue NameError
    if defined_on_singleton
      metaclass.send(:alias_method, method_name, aliased) rescue NameError
      metaclass.send(:undef_method, aliased) rescue NameError
    end
  end
end

module ActiveSupport
  class TestCase
    # Disable parallelization due to race conditions with custom stub implementation
    # parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
