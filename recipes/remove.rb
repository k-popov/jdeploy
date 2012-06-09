run_hook "pre_stop" do
    script_url node[:jdeploy][:app][:pre_stop]
end

service "#{node[:jdeploy][:app][:app_name]}" do
  action [ :stop, :disable ]
end

run_hook "pre_delete" do
    script_url node[:jdeploy][:app][:pre_delete]
end

# all methods are using /etc/init.d/app_name. Symlink if "runit"
file "/etc/init.d/#{node[:jdeploy][:app][:app_name]}" do
    action :delete
end

# if "runit" was used, remove it's service
if node[:jdeploy][:startup_method] == "runit"
    link "#{node[:runit][:service_dir]}/#{node[:jdeploy][:app][:app_name]}" do 
        action :delete
    end

    directory "#{node[:runit][:sv_dir]}/#{node[:jdeploy][:app][:app_name]}" do
        action :delete
        recurrsive true
    end
end

directory "#{node[:jdeploy][:app][:home_dir]}" do
    action :delete
    recursive true
end

# TODO Think about user deletion.
# Remove only if it was created.

run_hook "post_delete" do
    script_url node[:jdeploy][:app][:post_delete]
end
