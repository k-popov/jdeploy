# node[:jdeploy][:install_java] is a master manual switch.
if ( node[:jdeploy][:install_java] )
    if ( ! node[:languages][:java] ) || ( ! node[:languages][:java][:version] ) || \
        v1_older_v2( node[:languages][:java][:version], node[:jdeploy][:min_java_version] )
            include_recipe "java"
    end
end

# cleanup the directory if re-deploy requested
if node[:jdeploy][:redeploy] && File.exists?("#{node[:jdeploy][:app][:home_dir]}")
    include_recipe "jdeploy::remove"
end

# create a user and group for the app to run
if ! node[:etc][:passwd].keys.index(node[:jdeploy][:app][:user])
    # create the user only if it doesn't exist
    group "#{node[:jdeploy][:app][:group]}" do
        action :create
        gid node[:jdeploy][:app][:gid]
    end

    user "#{node[:jdeploy][:app][:user]}" do
        action :create
        home "#{node[:jdeploy][:app][:home_dir]}"
        gid "#{node[:jdeploy][:app][:group]}"
        uid node[:jdeploy][:app][:uid]
    end
end

directory "#{node[:jdeploy][:app][:home_dir]}" do
    action :create
    owner "#{node[:jdeploy][:app][:user]}"
    group "#{node[:jdeploy][:app][:group]}"
    mode "0755"
    recursive true
end

application_archive_file = filenameByUrl("#{node[:jdeploy][:app][:download_url]}")
require 'tmpdir'
app_tmp_dir = Dir.mktmpdir
File::chmod(0777, app_tmp_dir)
remote_file "#{app_tmp_dir}/#{application_archive_file}" do
    source "#{node[:jdeploy][:app][:download_url]}"
    mode "0644"
    owner "#{node[:jdeploy][:app][:user]}"
    group "#{node[:jdeploy][:app][:group]}"
    backup false
    action :create
end

run_hook "pre_unpack" do
    script_url node[:jdeploy][:app][:pre_unpack]
end

# if archive type is not overriden try to detect it
if node[:jdeploy][:app][:archive_type].empty?
	 archive_type = archiveTypeByUrl("#{node[:jdeploy][:app][:download_url]}")
end
# choose the right tool to extract the app
if archive_type == "zip"
    # unzip the file
    execute "unzip_file" do
        command "unzip #{app_tmp_dir}/#{application_archive_file}"
        cwd "#{node[:jdeploy][:app][:home_dir]}"
        user "#{node[:jdeploy][:app][:user]}"
        group "#{node[:jdeploy][:app][:group]}"
        environment ({'PATH' => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'})
    end
elsif archive_type == "tar.gz"
    # untar the file
    execute "untar_file" do
        command "tar -xvzf #{app_tmp_dir}/#{application_archive_file}"
        cwd "#{node[:jdeploy][:app][:home_dir]}"
        user "#{node[:jdeploy][:app][:user]}"
        group "#{node[:jdeploy][:app][:group]}"
        environment ({'PATH' => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'})
    end
else
    Chef::Application.fatal!("Unable to detect archive type: #{node[:jdeploy][:app][:download_url]}; Set node[:jdeploy][:app][:archive_type] to override.")
end

run_hook "post_unpack" do
    script_url node[:jdeploy][:app][:post_unpack]
end

# create additional required directories if any
if ! node[:jdeploy][:app][:dirs_to_create].empty?
    node[:jdeploy][:app][:dirs_to_create].each do |additional_dir|
        directory "#{additional_dir}" do
            action :create
            owner "#{node[:jdeploy][:app][:user]}"
            group "#{node[:jdeploy][:app][:group]}"
            mode "0755"
            recursive true
        end
    end
end

# generate properties file
if ! node[:jdeploy][:app][:config_file].empty?
    # Convert Chef::Node::Attribute to Hash
    if node[:jdeploy][:app][:config_properties]
        app_config_properties = node[:jdeploy][:app][:config_properties].to_hash
    end
    
    alter_properties "#{node[:jdeploy][:app][:config_file]}" do
        properties app_config_properties
        escape_special false
        skip_empty true
        create_file true
    end
end

run_hook "pre_start" do
    script_url node[:jdeploy][:app][:pre_start]
end
case node[:jdeploy][:startup_method]
    when "init"
        # add startup script and runn the app
        include_recipe "jdeploy::init_startup"
    when "custom"
        # final check if custom startup script may be used
        if ! node[:jdeploy][:custom_startup_url].empty?
            # use custom script for startup
            include_recipe "jdeploy::custom_startup"
        else
            include_recipe "jdeploy::init_startup"
        end
    when "runit"
        # use runit for application startup
        include_recipe "jdeploy::runit_startup"
end

if node[:jdeploy][:apache_proxy]
    # include the recipe from site-cookbooks (configure with i.e. JSON file)
    include_recipe "apache2::default_proxy"
end

