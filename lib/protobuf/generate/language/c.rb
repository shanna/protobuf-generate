require 'protobuf/generate/language'

module Protobuf
  module Generate
    class Language
      class C < Language
        match     %r{^ (?:gnu|[Cc]) (?:99|11) $}x
        templates Dir.glob(File.join(File.expand_path(File.dirname(__FILE__)), 'c', '*.erb'))

        #--
        # TODO: Base conventions with snake_case, camel_case and studly_caps converters.
        module Conventions
          def type     *name; snake_case *name, 't'    end
          def variable *name; snake_case *name         end
          def constant *name; snake_case(*name).upcase end
          def function *name; snake_case *name         end

          protected
            def snake_case *name
              name.compact.map(&:to_s).join('_').gsub(/([^A-Z_])([A-Z]+)/, '\1_\2').gsub(/[_.]+/, '_').downcase
            end
        end # Conventions

        #--
        # TODO: Break C into base class, c-static, c-dynamic.
        # @size_max is only required for static C.
        def initialize ast, conventions = Conventions
          validate ast
          ast.extend(conventions)
          super ast
        end

        private
          #--
          # TODO: Pass in validations as you do conventions.
          def validate ast
            ast.each do |e| # TODO: ast.messages
              next unless e.kind_of?(Protobuf::Generate::Ast::Message) # TODO: e.message?
              e.fields.each do |field|
                if field.label.match(/repeated/)
                  raise "Message %s.%s field repeating is unsupported." % [e.name, field.name]
                end
                if field.type.match(/string|bytes/) && field.meta["size"].to_i <= 0
                  raise "Message %s.%s %s field requires size meta comment > 0 // @size = DIGITS" % [e.name, field.name, field.type]
                end
              end
            end
          end
      end # C
    end # Langage
  end # Generate
end # Protobuf
