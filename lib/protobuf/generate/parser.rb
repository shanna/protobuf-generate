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
      rule(:comment_option_list) { (comment_option >> space?).repeat(1) }
      rule(:comment)             { str('//') >> (newline.absent? >> (comment_option_list.as(:meta) | any)).repeat >> newline }
      rule(:comment_list)        { comment.repeat }

      rule(:equals)        { str('=') >> whitespace? }
      rule(:bracket_open)  { str('{') >> whitespace? }
      rule(:bracket_close) { str('}') >> whitespace? }

      rule(:digit)   { match('[0-9]') }
      rule(:integer) { str('-').maybe >> match('[1-9]') >> digit.repeat }
      rule(:float)   { str('-').maybe >> digit.repeat(1) >> str('.') >> digit.repeat(1) }

      rule(:string_special)  { match['\0\t\n\r"\\\\'] }
      rule(:escaped_special) { str("\\") >> match['0tnr"\\\\'] }
      rule(:string)          { str('"') >> (escaped_special | string_special.absent? >> any).repeat >> str('"') }

      rule(:identifier)          { match('[a-zA-Z_]') >> match('[a-zA-Z0-9_]').repeat }
      rule(:identifier_dot_list) { identifier >> (str('.') >> identifier).repeat }

      rule(:constant) { identifier | integer | float | string }

      rule(:field_option)      { str('default').as(:name) >> whitespace? >> equals >> constant.as(:value) }
      rule(:field_option_list) { (str('[') >> whitespace? >> (field_option >> whitespace?).repeat(1) >> whitespace? >> str(']') >> whitespace?).as(:options) }
      rule(:field_type)        { identifier.as(:type) >> whitespace? }
      rule(:field_label)       { (str('required') | str('optional') | str('repeated')).as(:label) >> whitespace? }

      rule(:message_field)       { field_label >> field_type >> identifier.as(:name) >> whitespace? >> equals >> integer.as(:tag) >> whitespace? >> field_option_list.maybe >> str(';') >> space? >> comment.maybe.as(:comment) }
      rule(:message_field_list)  { (message_field >> whitespace?).repeat(1).as(:fields) }
      rule(:message)             { (comment_list.maybe.as(:comments) >> str('message') >> whitespace? >> identifier.as(:name) >> whitespace? >> bracket_open >> message_field_list.maybe >> bracket_close >> whitespace?).as(:message) }

      rule(:enum_field)      { identifier.as(:name) >> whitespace? >> equals >> integer.as(:tag) >> whitespace? >> str(';') }
      rule(:enum_field_list) { (enum_field >> whitespace?).repeat(1).as(:fields) }
      rule(:enum)            { (str('enum') >> whitespace? >> identifier.as(:name) >> whitespace? >> bracket_open >> enum_field_list >> bracket_close >> whitespace?).as(:enum) }

      rule(:package) { (str('package') >> whitespace? >> identifier_dot_list.as(:name) >> whitespace? >> str(';') >> whitespace?).as(:package) }

      rule(:expression) { whitespace? >> (package | enum | message | comment | whitespace).repeat }
      root(:expression)
    end # Parser

    class Transform < Parslet::Transform
      rule(comments: sequence(:c)) do
        puts "MATCH"
        true
        #comments.inject({}) do |acc, comment|
        #  comment[:meta].each{|m| acc[m[:name]] = m[:value]}
        #  acc
        #end
      end
    end
  end # Generate
end # Protobuf

