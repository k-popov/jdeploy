define :alter_properties, :file_name => nil,
                          :action => :create,
                          :create_file => false,
                          :skip_empty => false,
                          :remove_unparsed => true,
                          :escape_special => true do

    ruby_block "alter-properties-#{params[:name]}" do
        block do
            file_name = params[:file_name].nil? ? params[:name] : params[:file_name]
            properties = {}
            property_duplicates = {}
            params[:properties].each do |property_name, property_value|
                if property_value == nil
                    property_value = ""
                else
                    property_value = property_value.to_s
                    if params[:escape_special]
                        property_value.gsub!(/:/, "\\:")
                        property_value.gsub!(/=/, "\\=")
                    end
                end
                properties[property_name.to_s] = property_value
                property_duplicates[property_name.to_s] = property_value
            end
            if params[:create_file] and not File.exists?(file_name)
                Chef::Log.info("File #{file_name} does not exist and create_file option provided, creating new file")
                File.new(file_name, "w")
            end
            Chef::Log.info("Altering #{file_name}")
            Chef::Log.debug("Properties hash is #{properties.inspect}")
            File.open(file_name, 'r+') do |file|
                lines = file.readlines
                new_lines = []
                lines.each do |line|
                    line.chomp!()
                    line.strip!()
                    if line.match(/^#/) or line.length == 0
                        new_lines.push(line + $/)
                    else
                        regexp = Regexp.new('^([^=: ]+) *[=:] *([^ ]*.*)$')
                        match = regexp.match(line)
                        if match
                            property_name = match[1]
                            orig_property_value = match[2]
                            if property_name
                                if properties.has_key?(property_name.to_s)
                                    property_value = properties[property_name.to_s]
                                    if params[:skip_empty] and property_value == ""
                                        Chef::Log.debug("Adding #{property_name} as comment since value is empty and :skip_empty specified")
                                        new_lines.push("# " + line + $/)
                                    else
                                        Chef::Log.debug("Updating #{property_name}")
                                        new_lines.push(property_name + "=" + property_value.to_s + $/)
                                    end
                                    properties.delete(property_name.to_s)
                                elsif property_duplicates.has_key?(property_name.to_s)
                                    Chef::Log.debug("Duplicated property #{property_name}, removing dummy occurrence")
                                elsif orig_property_value == "" and params[:skip_empty]
                                    Chef::Log.debug("Adding #{property_name} as comment since value is empty and :skip_empty specified")
                                    new_lines.push("# " + line + $/)
                                else
                                    Chef::Log.debug("No mention about property #{property_name} in properties, leaving in place")
                                    new_lines.push(line + $/)
                                end
                            elsif not params[:remove_unparsed]
                                Chef::Log.debug("Line #{line} is unparsed, leaving in place since remove_unparsed is set to false")
                                new_lines.push(line + $/)
                            else
                                Chef::Log.warn("Unparsed line #{line}, removing")
                            end
                        elsif not params[:remove_unparsed]
                            Chef::Log.debug("Line #{line} is unparsed, leaving in place since remove_unparsed is set to false")
                            new_lines.push(line + $/)
                        else
                            Chef::Log.warn("Unparsed line #{line}, removing")
                        end
                    end
                end
                if new_lines[-1]
                    new_lines[-1] = new_lines[-1].chomp() + $/
                end
                properties.keys.sort.each do |property_name|
                    property_value = properties[property_name]
                    if not params[:skip_empty] or property_value != ""
                        Chef::Log.debug("Adding #{property_name} as it was missed from original file")
                        new_lines.push(property_name + "=" + property_value + $/)
                    else
                        Chef::Log.debug("Adding #{property_name} as comment since value is empty and :skip_empty specified")
                        new_lines.push("# " + property_name + "=" + $/)
                    end
                end
                file.pos = 0
                file.print new_lines
                file.truncate(file.pos)
            end
        end
        action params[:action]
    end

end
