# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Avoid using `Dir.chdir` due to its process-wide effect.
      #
      # @example
      #   # bad
      #   Dir.chdir("/var/run")
      #
      #   # bad
      #   FileUtils.chdir("/var/run")
      class DirChdir < Base
        MESSAGE = 'Avoid using `%<module>s.%<method>s` due to its process-wide effect.'
        RESTRICT_ON_SEND = %i[chdir cd].freeze

        # @!method chdir?(node)
        def_node_matcher :chdir?, <<~MATCHER
          {
            (send (const {nil? cbase} {:Dir :FileUtils}) :chdir ...)
            (send (const {nil? cbase} :FileUtils) :cd ...)
          }
        MATCHER

        def on_send(node)
          chdir?(node) do
            add_offense(
              node,
              message: format(MESSAGE, module: node.receiver.short_name, method: node.method_name)
            )
          end
        end
      end
    end
  end
end
