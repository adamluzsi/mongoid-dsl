module Mongoid
  module DSL

    module DumpHelper
      def mongoid_relations_dump_parse(obj)
        case obj

          when Class
            return {
                obj.to_s => {

                    'relations' => {
                        'one' => obj.relations.map{ |name,attributes|
                          if attributes[:relation].to_s.downcase =~ /embedded::one$/
                            mongoid_relations_dump_parse name.convert_model_name
                          end
                        }.compact,

                        'many' => obj.relations.map{ |name,attributes|
                          if attributes[:relation].to_s.downcase =~ /embedded::many$/
                            mongoid_relations_dump_parse name.convert_model_name
                          elsif attributes[:relation].to_s.downcase =~ /referenced::many$/
                            name.convert_model_name.to_s
                          end
                        }.compact,

                        'manytomany' => obj.relations.map{ |name,attributes|
                          if attributes[:relation].to_s.downcase =~ /manytomany$/
                            name.convert_model_name.to_s
                          end
                        }.compact
                    }.select{ |k,v| !v.empty? },
                    'attributes' => obj.properties.reduce({}){|m,o| m.merge!(o[0] => o[1].to_s) ;m}

                }.select{ |k,v| !v.empty? }
            }


          when Hash
            return obj

          when Array
            obj.reduce({}) do |m,e|
              case e

                when Class
                  m.merge!(mongoid_relations_dump_parse(e))

                when Hash
                  m.merge!(e)

                else
                  m.merge!(e => nil)

              end;m
            end

          else
            return obj

        end
      end

      def model_relations_dump
        mongoid_relations_dump_parse Mongoid.models.select{|klass| klass.parents.empty? }
      end

    end

  end

  extend DSL::DumpHelper

end
