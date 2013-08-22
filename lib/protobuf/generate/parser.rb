require 'parslet'

module Protobuf
  module Generate
    class Parser < Parslet::Parser
      rule(:newline)     { match('\n') }
      rule(:whitespace)  { match('\s').repeat(1) }
      rule(:whitespace?) { whitespace.maybe }
      rule(:space)       { match('[\t ]').repeat(1) }
      rule(:space?)      { space.maybe }

      rule(:comment_option)      { str('@') >> identifier.as(:name) >> space? >> equals >> constant.as(:value) }
      rule(:comment_option_list) { (comment_option.as(:option) >> space?).repeat(1) }
      rule(:comment)             { str('//') >> (newline.absent? >> (comment_option_list.as(:meta) | any)).repeat >> newline }
      rule(:comment_list)        { comment.repeat }

      rule(:equals)        { str('=') >> whitespace? }
      rule(:bracket_open)  { str('{') >> whitespace? }
      rule(:bracket_close) { str('}') >> whitespace? }

      rule(:digit)   { match('[0-9]') }
      rule(:integer) { str('-').maybe >> digit.repeat(1) }
      rule(:float)   { str('-').maybe >> digit.repeat(1) >> str('.') >> digit.repeat(1) }

      rule(:string_special)  { match['\0\t\n\r"\\\\'] }
      rule(:escaped_special) { str("\\") >> match['0tnr"\\\\'] }
      rule(:string)          { str('"') >> (escaped_special | string_special.absent? >> any).repeat >> str('"') }

      rule(:identifier)          { match('[a-zA-Z_]') >> match('[a-zA-Z0-9_]').repeat }
      rule(:identifier_dot_list) { identifier >> (str('.') >> identifier).repeat }

      rule(:constant) { identifier | integer | float | string }

      rule(:field_option)      { str('default').as(:name) >> whitespace? >> equals >> constant.as(:value) }
      rule(:field_option_list) { (str('[') >> whitespace? >> (field_option.as(:option) >> whitespace?).repeat(1) >> whitespace? >> str(']') >> whitespace?) }
      rule(:field_type)        { identifier.as(:type) >> whitespace? }
      rule(:field_label)       { (str('required') | str('optional') | str('repeated')).as(:label) >> whitespace? }

      rule(:message_field)       { (field_label >> field_type >> identifier.as(:name) >> whitespace? >> equals >> integer.as(:tag) >> whitespace? >> field_option_list.maybe.as(:options) >> str(';') >> space? >> comment.maybe.as(:comment) ).as(:message_field) }
      rule(:message_field_list)  { (message_field >> whitespace?).repeat(1).as(:fields) }
      rule(:message)             { (comment_list.maybe.as(:comments) >> str('message') >> whitespace? >> identifier.as(:name) >> whitespace? >> bracket_open >> message_field_list.maybe >> bracket_close >> whitespace?).as(:message) }

      rule(:enum_field)      { (identifier.as(:name) >> whitespace? >> equals >> integer.as(:tag) >> whitespace? >> str(';')).as(:enum_field) }
      rule(:enum_field_list) { (enum_field >> whitespace?).repeat(1).as(:fields) }
      rule(:enum)            { (str('enum') >> whitespace? >> identifier.as(:name) >> whitespace? >> bracket_open >> enum_field_list >> bracket_close >> whitespace?).as(:enum) }

      rule(:package) { (str('package') >> whitespace? >> identifier_dot_list.as(:name) >> whitespace? >> str(';') >> whitespace?).as(:package) }

      rule(:expression) { whitespace? >> (package | enum | message | comment | whitespace).repeat }
      root(:expression)
    end # Parser

    class Ast
      class Package < Struct.new(:name)
        def to_s; name end
      end
      class Message < Struct.new(:package, :name, :meta, :fields)
        def to_s; name end
        def empty?; fields.nil? or fields.empty? end
      end
      class MessageField < Struct.new(:label, :type, :name, :tag, :meta, :options)
        def required?; !!label.match(/required/) end
        def optional?; !required? end
      end
      class Enum < Struct.new(:package, :name, :fields)
        def to_s; name end
      end
      class EnumField < Struct.new(:name, :tag); end
    end

    class Transform < Parslet::Transform
      def apply slice, *args
        slice = super
        case slice
          when Ast::Package            then @package = slice
          when Ast::Message, Ast::Enum then slice.package = @package
        end
        slice
      end

      rule(option:  {name: simple(:name), value: simple(:value)}){ [name.to_s, value.to_s] }
      rule(package: {name: simple(:name)}){ Ast::Package.new(name.to_s) }

      rule(message_field: subtree(:f)) do
        Ast::MessageField.new(
          *f.values_at(:label, :type, :name, :tag).map(&:to_s),
          f[:comment].kind_of?(Array) ? Hash[*f[:comment].map{|c| c[:meta]}.flatten.compact] : {},
          f[:options].kind_of?(Array) ? Hash[*[f[:options]].flatten.compact] : {}
        )
      end

      rule(message: subtree(:message)) do
        Ast::Message.new(
          nil,
          message[:name].to_s,
          # TODO: Parslet should return nil not "" when empty. Figure out what's going on.
          message[:comments].kind_of?(Array) ? Hash[*message[:comments].map{|c| c[:meta]}.flatten.compact] : {},
          [*message[:fields]].compact
        )
      end

      rule(enum_field: {name: simple(:name), tag: simple(:tag)}){ Ast::EnumField.new(name.to_s, tag.to_s) }
      rule(enum: subtree(:enum)){ Ast::Enum.new(nil, enum[:name].to_s, enum[:fields]) }
    end # Transform
  end # Generate
end # Protobuf

