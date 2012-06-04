# cleanup the directory if re-deploy requested
if node[:jdeploy][:redeploy]
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

# TODO check the file type. Support .zip and .tar.gz
remote_file "#{node[:jdeploy][:tmp_dir]}/application.tar.gz" do
    source "#{node[:jdeploy][:app][:download_url]}"
    mode "0644"
    backup false
    action :create
end
    
