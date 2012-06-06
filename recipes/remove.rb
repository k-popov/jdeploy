run_hook "pre_stop" do
    script_url node[:jdeploy][:app][:pre_stop]
end

service "#{node[:jdeploy][:app][:app_name]}" do
  action [ :stop, :disable ]
end

run_hook "pre_delete" do
    script_url node[:jdeploy][:app][:pre_delete]
end

file "/etc/init.d/#{node[:jdeploy][:app][:app_name]}" do
    action :delete
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
