# cleanup the directory if re-deploy requested
if node[:jdeploy][:redeploy] && File.exists?("#{node[:jdeploy][:app][:home_dir]}")
    directory "#{node[:jdeploy][:app][:home_dir]}" do
        action :delete
        recursive true
    end
end

directory "#{node[:jdeploy][:app][:home_dir]}" do
    action :create
    owner "#{default[:jdeploy][:app][:user]}"
    group "#{default[:jdeploy][:app][:group]}"
    mode "0755"
    recursive true
end

application_archive_file = filenameByUrl("#{node[:jdeploy][:app][:download_url]}")
remote_file "#{node[:jdeploy][:tmp_dir]}/#{application_archive_file}" do
    source "#{node[:jdeploy][:app][:download_url]}"
    mode "0644"
    backup false
    action :create
end

# if archive type is not overriden try to detect it
if node[:jdeploy][:app][:archive_type].empty?
	 archive_type = archiveTypeByUrl("#{node[:jdeploy][:app][:download_url]}")
end
# choose the right tool to extract the app
if archive_type == "zip"
    # unzip the file
    execute "unzip_file" do
        command "unzip #{node[:jdeploy][:tmp_dir]}/#{application_archive_file}"
        cwd "#{node[:jdeploy][:app][:home_dir]}"
        user "#{default[:jdeploy][:app][:user]}"
        group "#{default[:jdeploy][:app][:group]}"
        environment ({'PATH' => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'})
    end
elif archive_type == "tar.gz"
    # untar the file
    execute "untar_file" do
        command "tar -xvzf #{node[:jdeploy][:tmp_dir]}/#{application_archive_file}"
        cwd "#{node[:jdeploy][:app][:home_dir]}"
        user "#{default[:jdeploy][:app][:user]}"
        group "#{default[:jdeploy][:app][:group]}"
        environment ({'PATH' => '/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin'})
    end
else
    Chef::Application.fatal!("Unable to detect archive type: #{node[:jdeploy][:app][:download_url]}; Set node[:jdeploy][:app][:archive_type] to override.")
end

# create additional required directories if any
if ! node[:jdeploy][:app][:dirs_to_create].empty?
    node[:jdeploy][:app][:dirs_to_create].each do |additional_dir|
        directory "#{additional_dir}" do
            action :create
            owner "#{default[:jdeploy][:app][:user]}"
            group "#{default[:jdeploy][:app][:group]}"
            mode "0755"
            recursive true
        end
    end
end
