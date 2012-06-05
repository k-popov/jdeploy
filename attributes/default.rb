# Set this to true to redeploy the app (remove its directory first)
default[:jdeploy][:redeploy] = true
default[:jdeploy][:min_java_version] = "1.6.0_31"

default[:jdeploy][:app][:home_dir] = "/opt/application"
default[:jdeploy][:app][:user] = "root"
default[:jdeploy][:app][:group] = "root"
default[:jdeploy][:app][:download_url] = "http://localhost:7777/app.tar.gz"
# default[:jdeploy][:app][:archive_type] = "" # set to override ArchiveTypeByUrl detection
default[:jdeploy][:app][:dirs_to_create] = [] # create additional directories for the app (i.e. logs, pids)
