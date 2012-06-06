template "/etc/init.d/#{node[:jdeploy][:app][:app_name]}" do
    source "app_init.erb"
    mode "0755"
    if params[:options].respond_to?(:has_key?)
      variables :options => params[:options]
    end
end

service "#{node[:jdeploy][:app][:app_name]}" do
    action [ :enable, :start ]
end
