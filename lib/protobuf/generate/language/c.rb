require 'protobuf/generate/language'

module Protobuf
  module Generate
    class Language
      class C < Language
        match     %r{^ (?:gnu|[Cc]) (?:99|11) $}x
        templates Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), 'c', '*.erb'))

        module Conventions
          def type     *name; snake_case *name, 't'    end
          def variable *name; snake_case *name         end
          def constant *name; snake_case(*name).upcase end
          def function *name; snake_case *name         end

          protected
            def snake_case *name
              name.map(&:to_s).join('_').gsub(/([^A-Z_])([A-Z]+)/, '\1_\2').gsub(/[_.]+/, '_').downcase
            end
        end # Conventions

        def initialize ast, conventions = Conventions
          ast.extend(conventions)
          super ast
        end
      end # C
    end # Langage
  end # Generate
end # Protobuf
