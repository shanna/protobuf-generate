require 'erubis'

module Protobuf
  module Generate
    class Language
      module Helpers
        def type_message? type
          !!find{|e| e.key?(:message) && e[:message][:name].to_s == type.to_s }
        end

        def type_enum? type
          !!find{|e| e.key?(:enum) && e[:enum][:name].to_s == type.to_s }
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
        Erubis::Eruby.new(File.read(eruby_filename)).evaluate(ast)
      end
    end # Language
  end # Generate
end # Protobuf
