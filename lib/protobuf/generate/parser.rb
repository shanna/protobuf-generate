require 'parslet'

module Protobuf
  module Generate
    class Parser < Parslet::Parser
      rule(:newline)  { match('\n').repeat(1) }
      rule(:space)    { match('\s').repeat(1) }
      rule(:spaces?)  { space.maybe }

      rule(:comment)   { str('//') >> (newline.absent? >> any).repeat >> spaces? }

      rule(:equals)        { str('=') >> spaces? }
      rule(:bracket_open)  { str('{') >> spaces? }
      rule(:bracket_close) { str('}') >> spaces? }

      rule(:digit)   { match('[0-9]') }
      rule(:integer) { str('-').maybe >> match('[1-9]') >> digit.repeat }
      rule(:float)   { str('-').maybe >> digit.repeat(1) >> str('.') >> digit.repeat(1) }

      rule(:string_special)  { match['\0\t\n\r"\\\\'] }
      rule(:escaped_special) { str("\\") >> match['0tnr"\\\\'] }
      rule(:string)          { str('"') >> (escaped_special | string_special.absent? >> any).repeat >> str('"') }

      rule(:identifier)          { match('[a-zA-Z_]') >> match('[a-zA-Z0-9_]').repeat }
      rule(:identifier_dot_list) { identifier >> (str('.') >> identifier).repeat }

      rule(:constant) { identifier | integer | float | string }

      rule(:field_option)      { str('default').as(:name) >> spaces? >> equals >> constant.as(:value) }
      rule(:field_option_list) { (str('[') >> spaces? >> (field_option >> spaces?).repeat(1) >> spaces? >> str(']') >> spaces?).as(:options) }
      rule(:field_type)        { (identifier >> spaces?).as(:type) }
      rule(:field_label)       { (str('required') | str('optional') | str('repeated')).as(:label) >> spaces? }

      rule(:message_field)       { field_label >> field_type >> identifier.as(:name) >> spaces? >> equals >> integer.as(:tag) >> spaces? >> field_option_list.maybe >> str(';') >> spaces? >> comment.maybe }
      rule(:message_field_list)  { (message_field >> spaces?).repeat(1).as(:fields) }
      rule(:message)             { (str('message') >> spaces? >> identifier.as(:name) >> spaces? >> bracket_open >> message_field_list >> bracket_close >> spaces?).as(:message) }

      rule(:enum_field)      { identifier.as(:name) >> spaces? >> equals >> integer.as(:tag) >> spaces? >> str(';') }
      rule(:enum_field_list) { (enum_field >> spaces?).repeat(1).as(:fields) }
      rule(:enum)            { (str('enum') >> spaces? >> identifier.as(:name) >> spaces? >> bracket_open >> enum_field_list >> bracket_close >> spaces?).as(:enum) }

      rule(:package) { (str('package') >> spaces? >> identifier_dot_list.as(:name) >> spaces? >> str(';') >> spaces?).as(:package) }

      rule(:expression) { spaces? >> (comment | package | enum | message).repeat }
      root(:expression)
    end # Parser
  end # Generate
end # Protobuf

