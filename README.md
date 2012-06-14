jdeploy
============
cloud4dev@griddynamics.com
============

Chef cookbook to deploy a generic java web-application running standalone

The cookbook is a result of attempt to create a more or less "generic" java
web application deployer. In general the cookbook will do the following:

 - Install java using "java" cookbook (OpsCode's one needs additional
   JSON arguments) if master switch "install_java" is set to true
   and the version of java already installed is lover than "min_java_version"
   specified (version check based on ohai data).

 - Create a user to run the application (if a user other than root specified).

 - Download the archive with the webapp, try to guess it's type
   (.zip and .tar.gz are currently supported) and unpack it
   to the application home directory specified. Archive type
   may be overriden by setting "node[:jdeploy][:app][:archive_type]".

 - Create a list of additional reured directories (i.e. for logs.pids)

 - Generate a configuration (properties) file in the "key = value"
   format based on "node[:jdeploy][:app][:config_properties]" hash
   keys and values and write it into the file specified.

 - Make the application start at the system startup either with
   a simple script in /etc/init.d/ or with "runit" dupervision system.
   It's possibe to specify a custom init.d script or pass
   required arguments to a standard one.

 - Run the application with one of the methods specified above with
   user chosen with "node[:jdeploy][:app][:user]".

 - Apache reverse proxying with optional SSL offloading will be
   configured if requested.

 - Note the node[:jdeploy][:app][:(pre|post)_<action>] parameters.
   These are URLs for downloading the hook scripts which will be
   run during the different phases of deployment.
   Hook scripts attributes names are self-explanatory or see the code.

 - A small "jdeploy::remove" recipe will stop the application,
   remove the application directory and disable it's auto-start.
   Because of runsvdir strange behavior removal recipe is not deleteing
   runit service definition files/directories. May be a TODO.


A sample JSON file:

{
"jdeploy": {
    "install_java": false,
    "java_home": "/usr",
    "min_java_version": "1.6.0_31",
    "app": {
        "home_dir": "/opt/application",
        "user": "root",
        "group": "root",
        "download_url": "http://example.com/application.tar.gz",
        "dirs_to_create": ["/opt/application/logs", "/opt/application/pids"],
        "app_name": "application",
        "start_cmdline": "-XX:MaxPermSize=256m -Dbackend.properties=file:$APP_HOME/application.properties -cp \"$APP_HOME/*\" com.example.application.MainClass",
        "stdout_log": "/opt/application/logs/stdout.log",
        "pid_file": "/opt/application/pids/application.pid",
        "config_file": "/opt/application/application.properties",
        "config_properties": {
            "application.string.property1" : "value1",
            "application.string.property2" : "value2",
            "application.numeric.property" : 42,
            "application.boolean.property" : false
            }
        },
    "startup_method": "init",
    "custom_startup_url": "",
    "apache_proxy": true
    },
"apache": {
    "default_proxy": {
        "read_thru_locations": {
            "logs": false,
            "conf": false
            },
        "ssl_offload": true
        },
        "port": 80,
        "port_secure": 443,
        ":proxy_port": 8080,
        "https_enabled": true,
        "https_forward": false
    }
}

