module Mongoid
  module DSL

    module Document

      module Extend

        def documents

              exceptions= %w[
            Mongoid::Relations::Embedded::In
            Mongoid::Relations::Referenced::In
          ]

          return_array = Array.new
          self.relations.each do |model_name,module_propertys|
            if !exceptions.include?(module_propertys[:relation].to_s)
              return_array.push model_name
            end
          end

          return return_array
        rescue Exception
          return []

        end

        def relation_connection_type(to_model)
          begin

            return_none= "Mongoid::Relations::None"
            return_self= "Mongoid::Relations::Self"

            if to_model.nil?
              return return_none
            end

            if self.to_s == to_model.to_s
              return return_self
            end

            relation_type_data= self.reflect_on_association(to_model.convert_model_name)

            if relation_type_data.nil?
              return return_none
            else
              return relation_type_data[:relation].to_s
            end

          end
        end
        def reverse_relation_conn_type(from_model)
          begin

            return_none= "Mongoid::Relations::None"
            return_self= "Mongoid::Relations::Self"

            if from_model.nil?
              return return_none
            end

            if self.to_s == from_model.to_s
              return return_self
            end

            relation_type_data= from_model.reflect_on_association(self.convert_model_name)

            if relation_type_data.nil?
              return return_none
            else
              return relation_type_data[:relation].to_s
            end

          end
        end

        def properties

          hash_data = Hash.new
          self.fields.each do |key,value|
            hash_data[value.name]=value.options[:type]
          end
          return hash_data

        end

        def parents
          begin

            exceptions= %w[
          Mongoid::Relations::Embedded::In
        ]

            return_array = Array.new
            self.relations.each do |model_name,module_propertys|
              if exceptions.include?(module_propertys[:relation].to_s)
                return_array.push model_name
              end
            end
            return return_array

          end
        end
        def references
          begin

            exceptions= %w[
          Mongoid::Relations::Referenced::In
          Mongoid::Relations::Referenced::ManyToMany
        ]

            return_array = Array.new
            self.relations.each do |model_name,module_propertys|
              if exceptions.include?(module_propertys[:relation].to_s)
                return_array.push model_name
              end
            end
            return return_array

          end
        end

        def _get_class_path(*included)

          # create defaults
          begin
            return_array= Array.new()
            check_list= Array.new#.push(self.to_s)
            relations_hash = Hash.new()
            #chains= Hash.new
            chains= Array.new
          end

          # get parents for every participants
          begin
            models_to_check = Array.new.push self
            loop do
              tmp_array = Array.new
              break if models_to_check.empty?
              models_to_check.each do |one_models_element|
                begin
                  one_models_element.parents.each do |one_parent_in_underscore|
                    parent_model= one_parent_in_underscore.convert_model_name
                    tmp_array.push parent_model if !relations_hash.keys.include?(parent_model)
                    relations_hash[one_models_element] ||= Array.new
                    relations_hash[one_models_element].push parent_model
                  end
                rescue NoMethodError
                  #next
                end
              end
              models_to_check= tmp_array
            end
            models_to_check.clear
          end

          # make connections from relation pairs
          begin

            # generate pre path chains
            # minden egyes szulo,s szulo szulo elemen egyesevel menj vegig (csak elso elemet vizsgalva) es ahol tobb mint egy elem talalhato azt torold
            # igy legkozelebb az mar nem lesz lehetseges utvonal, ahol pedig mindenhol csak 1 elem volt  ott ellenorzid
            # hogy mar megtalalt sorrol van e szo, s ha igen torold a relations_hash[self] ből ezt a szulot (2. elem a path ban)
            # the goal is to get every 1 element from sub arrays

            begin
              available_paths= Array.new
              return nil if relations_hash[self].nil?
              loop do

                # defaults
                begin
                  next_element_to_find  = self
                  delete_element        = Hash.new
                  one_chain             = Array.new
                end

                # chain element builder
                begin
                  loop do
                    if !relations_hash[next_element_to_find].nil? && relations_hash[next_element_to_find] != Array.new

                      one_chain.push(relations_hash[next_element_to_find][0])
                      if relations_hash[next_element_to_find].count > 1
                        delete_element       = Hash.new
                        delete_element[next_element_to_find]= relations_hash[next_element_to_find][0]
                      end

                      next_element_to_find= relations_hash[next_element_to_find][0]
                    else
                      break
                    end
                  end
                end

                # remove already checked tree
                begin
                  if delete_element != Hash.new
                    relations_hash[delete_element.keys[0]].delete_at(
                        relations_hash[delete_element.keys[0]].index(
                            delete_element[delete_element.keys[0]]))
                    delete_element= Hash.new
                  end
                end

                # add new element to chains
                begin
                  unless chains.include? one_chain
                    chains.push one_chain
                  else
                    break
                  end
                end
              end

            end

          end

          # after format and check params for contains
          begin

            # pre chains trim
            begin

              tmp_array= Array.new
              chains.each do |one_element|
                if !one_element.contain?(included)
                  tmp_array.push one_element
                end
              end
              tmp_array.each do |one_element_to_delete|
                chains.delete_at(chains.index(one_element_to_delete))
              end

            end

            # choose the shortest path
            begin
              chain_list_max_count= nil
              chains.each do |one_chain_list|
                counter= one_chain_list.count
                chain_list_max_count ||= (counter+1)
                if counter < chain_list_max_count
                  return_array= one_chain_list
                  counter= chain_list_max_count
                end
              end
            end

            # reverse array
            begin
              return_array.reverse!
            end

            # add new element as self for first
            begin
              return_array.push self
            end


          end

          return return_array
        end

        def __query_wrapper(*args)

          # defaults
          begin
            return_data= nil
            # params field
            field_hash= Hash.new
            # models
            models_container= Array.new
            # mother model
            mother_model= nil
            # method_to_use
            method_to_use= Hash.new

            args.each do |one_argument|
              case true

                when one_argument.class <= String
                  begin
                    field_hash['_id']= Moped::BSON::ObjectId.from_string(one_argument)
                  rescue
                    begin
                      models_container.push one_argument.constantize
                    rescue NameError
                      #method_to_use= one_argument
                    end
                  end

                when one_argument.class <= Hash
                  begin
                    one_argument.each do |key,value|
                      if key.to_s == '_id'
                        field_hash['_id']= Moped::BSON::ObjectId.from_string(value.to_s)
                      else
                        field_hash[key]=value
                      end
                    end
                  end

                when one_argument.class <= Class
                  models_container.push one_argument

                when one_argument.class <= Array
                  method_to_use= one_argument

              end
            end

          end

          # mother model find, and path generate
          begin

            full_path   = self._get_class_path(*models_container)  || Array.new.push(self)
            mother_model= full_path.shift

            full_path.count.times do |index|
              full_path[index]= full_path[index].convert_model_name
            end

          end

          # path trim
          begin

            deep_level = (full_path.count) || 0
            chains= full_path

            if !full_path.empty? && !full_path.nil?
              full_path= full_path.join('.')+'.'
            else
              full_path= String.new
            end

          end

          # start query
          begin

            # build app query args
            begin

              gen_field_hash= lambda { |query_hash,*pre_path_elements|
                query_fields= Hash.new()

                full_path_str= nil
                if !pre_path_elements.empty? && !pre_path_elements.nil?
                  full_path_str= pre_path_elements.join('.')+'.'
                else
                  full_path_str= ""
                end

                return query_hash.map_hash { |key,value|
                  { "#{full_path_str}#{key}" => value }
                }


              }

              query_fields= gen_field_hash.call field_hash, *chains

            end

            # do query ask from db
            begin
              if method_to_use[1][:arguments?]
                query_data = mother_model.__send__(
                    method_to_use[0].to_s,
                    query_fields)
              else
                query_data = mother_model.__send__(
                    method_to_use[0].to_s)
              end
            end

            # return data level
            begin

              if deep_level == 0
                return_data=query_data
              else

                # go down for embeds docs
                begin

                  last_round   = (chains.count-1)
                  map_object   = query_data
                  return_array = [] #> Mongoid::Criteria.new
                  chains.count.times do |deepness|
                    begin
                      children = Array.new
                      if map_object.class == Array || map_object.class == Mongoid::Criteria

                        map_object.each do |one_element_of_the_map_array|
                          subclass_data = one_element_of_the_map_array.__send__(chains[deepness])
                          if subclass_data.class <= Array || subclass_data.class <= Mongoid::Criteria
                            subclass_data.each do |one_element_of_tmp_children|
                              if deepness < last_round
                                children.push one_element_of_tmp_children
                              else
                                return_array.push one_element_of_tmp_children
                              end
                            end
                          else
                            if deepness < last_round
                              children.push subclass_data
                            else
                              return_array.push subclass_data
                            end
                          end
                        end

                      else
                        subclass_data = map_object.__send__(chains[deepness])
                        if subclass_data.class == Array || subclass_data.class == Mongoid::Criteria
                          subclass_data.each do |one_element_of_tmp_children|
                            if deepness < last_round
                              children.push one_element_of_tmp_children
                            else
                              return_array.push one_element_of_tmp_children
                            end
                          end
                        else
                          if deepness < last_round
                            children.push subclass_data
                          else
                            return_array.push subclass_data
                          end
                        end
                      end
                      map_object=children.uniq
                    rescue NoMethodError => ex
                      STDERR.puts(ex)
                    end
                  end

                  return_data= return_array

                end
              end
            end

            # trim not used class
            if method_to_use[1][:arguments?]

              tmp_array= []
              return_data.map! { |one_element|

                tmp_hash= one_element.convert_to_hash#instance_variables.each{ |var| tmp_hash[var.to_s.delete("@")] = one_element.instance_variable_get(var) }

                if tmp_hash["attributes"].deep_include?(field_hash) || tmp_hash["attributes"].deep_include?(field_hash.map_hash{|k,v|[k.to_s,v]})
                  one_element
                else
                  nil
                end

              }.compact!

            end


          end

          # TODO find out how to add elements to a criteria obj
          # # convert to mongid criteria
          # begin
          #
          #   mongoid_crit= Mongoid::Criteria.new(self)
          #
          #   puts mongoid_crit.methods - Object.methods
          #
          #
          #   mongoid_crit.add_to_set return_data[0]
          #
          #   return mongoid_crit
          #
          # rescue Exception
          # end

          return return_data

        end

        def _where(*args)
          self.__query_wrapper(['where',{:arguments? => true}],*args)
        end
        def _all(*args)
          self.__query_wrapper(['all',{:arguments? => false}],*args)
        end

        def _find(target_id)

          # pre validation
          begin
            if target_id.class != Moped::BSON::ObjectId && target_id.class != String
              raise ArgumentError, "id parameter must be id or ObjectId"
            end
          end

          # Do the Gangnam style
          begin
            return_doc = self._where( '_id' => target_id )[0]
          end

          return return_doc
        end
        def _find_by(*args)

          # Do the Gangnam style
          begin
            return_array = self._where(*args).first
          end

          return return_array
        end

        #> [:none,:self,:one,:many]
        def relation_to?(klass)
          raise(ArgumentError,"obj must be class: #{klass}") unless klass <= Class
          return self.relation_connection_type(klass).to_s.downcase.split('::').last.to_sym
        end

        #> [:none,:self,:one,:many]
        def relation_from?(klass)
          raise(ArgumentError,"obj must be class: #{klass}") unless klass <= Class
          return self.reverse_relation_conn_type(klass).to_s.downcase.split('::').last.to_sym
        end

      end

      module Include

        def _parent

          self.class.parents.each do |parent_underscore_name|
            if self.__send__("has_#{parent_underscore_name}?") == true
              return self.__send__(parent_underscore_name)
            end
          end
          return nil

        end
        alias __parent__ _parent

        def _reference

          self.class.references.each do |parent_underscore_name|
            if self.__send__("has_#{parent_underscore_name}?") == true
              return self.__send__(parent_underscore_name)
            end
          end
          return nil

        end
        alias __reference__ _reference

        alias :get_parent_doc     :_parent
        alias :get_reference_doc  :_reference

      end

    end

    module StringExt
      module Include
        def to_ObjectId
          begin
            Moped::BSON::ObjectId.from_string(self.to_s)
          rescue Exception => ex
            ex.logger
            nil
          end
        end
      end
    end

    module CoreExt

      module Include

        # convert mongoid name
        def convert_model_name

          unless self.class <= ::Class || self.class <= ::String || self.class <= ::Symbol || self.class <= ::NilClass
            return super;# raise ArgumentError, "invalid input, must be Class or String: => #{self.class} (#{self})"
          end

          if self.class <= ::NilClass
            return nil
          end

          case true

            when self.class == ::Class
              return self.to_s.split('::').last.underscore

            when ![ ::Symbol, ::String].select{ |klass|self.class <= klass }.empty?

              Mongoid.models.each do |model_name|
                mongoid_model_name= model_name.mongoid_name
                unless [mongoid_model_name,mongoid_model_name+'s'].select{|mn| self.to_s == mn }.empty?
                  return model_name.to_s.constantize
                end
              end

              return self.to_s.split('::').last.underscore

          end

          return nil
        end

        alias :mongoise_name        :convert_model_name
        alias :mongoize_name        :convert_model_name
        alias :mongoid_name         :convert_model_name

      end

    end

    # for manual include
    self.__send__ :include, Mongoid::DSL::Document::Include
    def self.included klass
      klass.__send__ :extend,Mongoid::DSL::Document::Extend
    end

  end
end

begin

  Mongoid::Config.inject_singleton_method :register_model, add: :before do |klass|
    klass.__send__ :extend,  Mongoid::DSL::Document::Extend
    klass.__send__ :include, Mongoid::DSL::Document::Include
  end

rescue NoMethodError
end

[
    Class,
    Symbol,
    NilClass,
    String
].each do |class_name|
  class_name.__send__ :include, Mongoid::DSL::CoreExt::Include
end

String.__send__ :include, Mongoid::DSL::StringExt::Include