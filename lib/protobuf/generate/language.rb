require 'erubis'

module Protobuf
  module Generate
    class Language
      module Helpers
        def type_message? type
          !!find{|e| e.kind_of?(Protobuf::Generate::Ast::Message) && e.name == type }
        end

        def type_enum? type
          !!find{|e| e.kind_of?(Protobuf::Generate::Ast::Enum) && e.name == type }
        end

        def type_wire type
          Hash[*%w{int32 0 int64 0 sint32 0 sint64 0 uint32 0 uint64 0 string 2 bool 0 float 5 double 1 fixed32 5 fixed64 1 sfixed32 5 sfixed64 1 bytes 2}][type]
        end

        def type_enum_default type, default
          enum = find{|e| e.kind_of?(Protobuf::Generate::Ast::Enum) && e.name == type} # TODO: Or raise unknown type.
          (enum.fields.find{|f| f.name == default.to_s} || enum.fields.first).name
        end
      end

      def self.match language = nil
        @language = language if language
        @language
      end

      def self.templates templates = nil
        @templates = templates if templates
        @templates
      end

      def self.find language
        @@languages.find{|l| l.match(language.to_s)}
      end

      def self.inherited klass
        (@@languages ||= []) << klass
      end

      def initialize ast
        @ast = ast
      end

      def templates
        self.class.templates
      end

      def generate eruby_filename
        ast = @ast
        ast.extend(Helpers)
        Erubis::Eruby.new(File.read(eruby_filename), filename: eruby_filename).evaluate(ast)
      end
    end # Language
  end # Generate
end # Protobuf
