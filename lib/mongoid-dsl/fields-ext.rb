# Validates whether the value of the specified attribute is available in a
# particular enumerable object.
#
#   class Person < ActiveRecord::Base
#     validates_inclusion_of :gender, :in => %w( m f )
#     validates_inclusion_of :age, :in => 0..99
#     validates_inclusion_of :format, :in => %w( jpg gif png ), :message => "extension %{value} is not included in the list"
#     validates_inclusion_of :states, :in => lambda{ |person| STATES[person.country] }
#   end
#
# Configuration options:
# * <tt>:in</tt> - An enumerable object of available items. This can be
#   supplied as a proc or lambda which returns an enumerable. If the enumerable
#   is a range the test is performed with <tt>Range#cover?</tt>
#   (backported in Active Support for 1.8), otherwise with <tt>include?</tt>.
# * <tt>:within</tt> - A synonym(or alias) for <tt>:in</tt>
# * <tt>:message</tt> - Specifies a custom error message (default is: "is not
#   included in the list").
# * <tt>:allow_nil</tt> - If set to true, skips this validation if the attribute
#   is +nil+ (default is +false+).
# * <tt>:allow_blank</tt> - If set to true, skips this validation if the
#   attribute is blank (default is +false+).
# * <tt>:on</tt> - Specifies when this validation is active. Runs in all
#   validation contexts by default (+nil+), other options are <tt>:create</tt>
#   and <tt>:update</tt>.
# * <tt>:if</tt> - Specifies a method, proc or string to call to determine if
#   the validation should occur (e.g. <tt>:if => :allow_validation</tt>, or
#   <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>). The method, proc
#   or string should
#   return or evaluate to a true or false value.
# * <tt>:unless</tt> - Specifies a method, proc or string to call to determine
#   if the validation should not occur (e.g. <tt>:unless => :skip_validation</tt>,
#   or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>). The method,
#   proc or string should return or evaluate to a true or false value.
# * <tt>:strict</tt> - Specifies whether validation should be strict.
#   See <tt>ActiveModel::Validation#validates!</tt> for more information.

[ :desc, :description, :comment ].each do |name_to_use|
  Mongoid::Fields.option name_to_use do |model, field, value|

    if field.instance_variable_get('@options')[name_to_use].class <= Array
      field.instance_variable_get('@options')[name_to_use]= field.instance_variable_get('@options')[name_to_use].join
    end

    field.instance_variable_get('@options')[:desc]= field.instance_variable_get('@options').delete(name_to_use)

  end
end

[ :required, :present, :presence, :need ].each do |name_to_use|
  Mongoid::Fields.option name_to_use do |model, field, value|

    field.instance_variable_get('@options')[:presence]= field.instance_variable_get('@options').delete(name_to_use)
    if value == true
      model.instance_eval do
        validates_presence_of field.instance_variable_get('@name')
      end
    end

  end
end

[ :uniq, :unique, :uniqueness ].each do |name_to_use|
  Mongoid::Fields.option name_to_use do |model, field, value|

    field.instance_variable_get('@options')[:uniqueness]= field.instance_variable_get('@options').delete(name_to_use)
    if value == true
      model.instance_eval do
        validates_uniqueness_of field.instance_variable_get('@name')
      end
    end

  end
end

[ :accept, :accept_only, :can, :can_be, :only, :inclusion ].each do |name_to_use|
  Mongoid::Fields.option name_to_use do |model, field, value|

    field.instance_variable_get('@options')[:inclusion]= field.instance_variable_get('@options').delete(name_to_use)
    model.instance_eval do

      validates_inclusion_of field.instance_variable_get('@name'),
                             in: [*value]

    end

  end
end

[ :deny, :denied, :denied_only, :not, :exclude, :exclusion ].each do |name_to_use|
  Mongoid::Fields.option name_to_use do |model, field, value|

    field.instance_variable_get('@options')[:exclusion]= field.instance_variable_get('@options').delete(name_to_use)
    model.instance_eval do

      validates_exclusion_of field.instance_variable_get('@name'),
                             in: [*value]

    end

  end
end


[ :with, :match, :regex, :regexp ].each do |name_to_use|
  Mongoid::Fields.option name_to_use do |model, field, value|

    field.instance_variable_get('@options')[:format]= field.instance_variable_get('@options').delete(name_to_use)
    model.instance_eval do

      if value.class <= Regexp

        validates_format_of field.instance_variable_get('@name'),
                            with: value

      elsif value.class <= Array

        validates_format_of field.instance_variable_get('@name'),
                            in: value

      else
        raise ArgumentError,"invalid regexp: #{value}"
      end

    end

  end
end


[ :without, :not_match, :cant_be_regex, :cant_be_regexp ].each do |name_to_use|
  Mongoid::Fields.option name_to_use do |model, field, value|

    field.instance_variable_get('@options')[:format]= field.instance_variable_get('@options').delete(name_to_use)
    model.instance_eval do

      if value.class <= Regexp

        validates_format_of field.instance_variable_get('@name'),
                            without: value

      else
        raise ArgumentError,"invalid regexp: #{value}"
      end

    end

  end
end

[ :length ].each do |name_to_use|
  Mongoid::Fields.option name_to_use do |model, field, value|

    field.instance_variable_get('@options')[:format]= field.instance_variable_get('@options').delete(name_to_use)
    model.instance_eval do

      if value.class <= Hash

        options_to_use= {}

        [:max,:maximum,'max','maximum'].each do |key_name|
          options_to_use[:maximum] ||= value[key_name]
        end

        [:min,:minimum,'min','minimum'].each do |key_name|
          options_to_use[:minimum] ||= value[key_name]
        end

        [:within,:range,'within','range'].each do |key_name|
          options_to_use[:within] ||= value[key_name]
        end

        validates_length_of field.instance_variable_get('@name'),
                            options_to_use

      else
        raise ArgumentError,"invalid Hash obj: #{value}"
      end

    end

  end
end

[:hidden,:hide].each do |name_to_use|
  Mongoid::Fields.option name_to_use do |model, field, value|

    field.instance_variable_get('@options')[:hidden]= field.instance_variable_get('@options').delete(name_to_use)

    if value
      model.instance_eval do

        begin
          self.class_variable_get(:@@mongoid_dsl_hidden_fields)
        rescue NameError

          self.class_variable_set :@@mongoid_dsl_hidden_fields, []
          [:hidden,:hide].each { |sym| scope sym, -> { without(*self.class_variable_get(:@@mongoid_dsl_hidden_fields)) } }

          unless default_scoping?
            default_scope -> { hidden }
          end

        end

        self.class_variable_get(:@@mongoid_dsl_hidden_fields).push(field.instance_variable_get(:@name)) if !!value

      end
    end

  end
end

[:index].each do |name_to_use|
  Mongoid::Fields.option name_to_use do |model, field, value|

    field.instance_variable_get('@options')[:index]= field.instance_variable_get('@options').delete(name_to_use)

    if value
      model.instance_eval do

        begin
          self.class_variable_get(:@@mongoid_dsl_index_fields)
        rescue NameError
          self.class_variable_set :@@mongoid_dsl_index_fields, [{},{}]
        end

        case

          when value.class <= Hash
            self.class_variable_get(:@@mongoid_dsl_index_fields)[0].merge!(value)

          when value.class <= Array
            2.times do |index_number|
              if value[index_number].class <= Hash
                self.class_variable_get(:@@mongoid_dsl_index_fields)[index_number].merge!(value[index_number])
              end
            end

          when value.class <= TrueClass
            self.class_variable_get(:@@mongoid_dsl_index_fields)[0].merge!(
                {field.instance_variable_get(:@name) => 1}
            )

          when value.class <= Numeric && (-1..1).include?(value)
            self.class_variable_get(:@@mongoid_dsl_index_fields)[0].merge!(
                {field.instance_variable_get(:@name) => value}
            )

        end

        if self.class_variable_get(:@@mongoid_dsl_index_fields)[0].respond_to?(:empty?) && !self.class_variable_get(:@@mongoid_dsl_index_fields)[0].empty?
          index(*(self.class_variable_get(:@@mongoid_dsl_index_fields).select{|e| e.respond_to?(:empty?) && !e.empty? }))
        end

      end
    end

  end
end