include_recipe "runit"

runit_service "#{node[:jdeploy][:app][:app_name]}" do
    template_name "application"
end

# fix permissions for the log writer (for application user could write logs)
directory "#{node[:runit][:service_dir]}/#{node[:jdeploy][:app][:app_name]}/log/main" do
    action :create
    mode "0755"
    owner "#{node[:jdeploy][:app][:user]}"
    group "#{node[:jdeploy][:app][:group]}"
    recursive true
end

