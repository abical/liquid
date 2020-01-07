# frozen_string_literal: true

require 'set'

module Liquid
  # StrainerTemplate is the computed class for the filters system.
  # New filters are mixed into the strainer class which is then instantiated for each liquid template render run.
  #
  # The Strainer only allows method calls defined in filters given to it via StrainerFactory.add_global_filter,
  # Context#add_filters or Template.register_filter
  class StrainerTemplate
    def initialize(context)
      @context = context
    end

    class << self
      def add_filter(mod)
        filter_klass = Class.new do
          include(mod)

          def initialize(context)
            @context = context
          end
        end

        methods = mod.public_instance_methods
        methods.each do |method|
          filter_class_by_methods[method.to_s] = filter_klass
        end
      end

      def invokable?(method)
        filter_class_by_methods.key?(method.to_s)
      end

      def filter_class_for_methods(method)
        filter_class_by_methods[method.to_s]
      end

      private

      def filter_class_by_methods
        @filter_class_by_methods ||= {}
      end
    end

    def invoke(method, *args)
      if self.class.invokable?(method)
        klass = self.class.filter_class_for_methods(method)
        instance = klass.new(@context)
        instance.public_send(method, *args)
      elsif @context&.strict_filters
        raise Liquid::UndefinedFilter, "undefined filter #{method}"
      else
        args.first
      end
    rescue ::ArgumentError => e
      raise Liquid::ArgumentError, e.message, e.backtrace
    end
  end
end
