include_recipe "runit"

runit_service "#{node[:jdeploy][:app][:app_name]}" do
    template_name "application"
end
