# Set this to true to redeploy the app (remove its directory first)
default[:jdeploy][:redeploy] = true
default[:jdeploy][:tmp_dir] = "/tmp"

default[:jdeploy][:app][:home_dir] = "/opt/application"
default[:jdeploy][:app][:user] = "root"
default[:jdeploy][:app][:group] = "root"
default[:jdeploy][:app][:download_url] = "http://localhost:7777/app.tar.gz"
