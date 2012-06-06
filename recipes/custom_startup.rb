remote_file "/etc/init.d/#{node[:jdeploy][:app][:app_name]}" do
    source "#{node[:jdeploy][:custom_startup_url]}"
    mode "0755"
    action :create
end

service "#{node[:jdeploy][:app][:app_name]}" do
    action [ :enable, :start ]
end
