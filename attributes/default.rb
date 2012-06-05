# Set this to true to redeploy the app (remove its directory first)
default[:jdeploy][:redeploy] = true
default[:jdeploy][:java_home] = "/usr"
default[:jdeploy][:min_java_version] = "1.6.0_31"

default[:jdeploy][:app][:home_dir] = "/opt/application"
default[:jdeploy][:app][:user] = "root"
default[:jdeploy][:app][:group] = "root"
default[:jdeploy][:app][:download_url] = "http://localhost:7777/app.tar.gz"
# default[:jdeploy][:app][:archive_type] = "" # set to override ArchiveTypeByUrl detection
default[:jdeploy][:app][:dirs_to_create] = [] # create additional directories for the app (i.e. logs, pids)

# specify URLs to hook scripts. Leave empty if unnecessary
default[:jdeploy][:app][:pre_unpack] = ""
default[:jdeploy][:app][:post_unpack] = ""
default[:jdeploy][:app][:pre_start] = ""

# name of the application
default[:jdeploy][:app][:app_name] = "app"
# application startup commandline
# (i.e. "/usr/bin/java node[:jdeploy][:app][:start_cmdline] ")
default[:jdeploy][:app][:start_cmdline] = '-XX:MaxPermSize=256m -cp "$APP_HOME/*" com.exmple.app.mainClass'
# application STDOUT redirection file
default[:jdeploy][:app][:stdout_log] = "/var/log/#{node[:jdeploy][:app][:app_name]}"
# File to store PID of the application
default[:jdeploy][:app][:pid_file] = "/var/run/#{node[:jdeploy][:app][:app_name]}"
