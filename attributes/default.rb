# Set this to true to redeploy the app (remove its directory first)
default[:jdeploy][:redeploy] = true
# JAVA_HOME in for example init script
default[:jdeploy][:java_home] = "/usr"
# minimal java version
# (java will be installed only if the existing version is older than specified here)
default[:jdeploy][:min_java_version] = "1.6.0_31"

# Application home dir. The app will be unpacked here
default[:jdeploy][:app][:home_dir] = "/opt/application"
# user and group the app to own and to run
default[:jdeploy][:app][:user] = "root"
default[:jdeploy][:app][:group] = "root"
# UID and GID may also be speecified (optional)
# default[:jdeploy][:app][:gid] = ""
# default[:jdeploy][:app][:uid] = ""

# URL to download the application
default[:jdeploy][:app][:download_url] = "http://localhost:7777/app.tar.gz"
# set to override ArchiveTypeByUrl detection
# default[:jdeploy][:app][:archive_type] = ""
# create additional directories for the app (i.e. logs, pids)
default[:jdeploy][:app][:dirs_to_create] = []

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

# hash of properties for config file genenration
# the file will look like: <hash_key> = <hash_value>
default[:jdeploy][:app][:config_properties] = {}
# config file to generate. Leave empty not to generate
default[:jdeploy][:app][:config_file] = ""
