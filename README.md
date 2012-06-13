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
        "home_dir": "/opt/genesis",
        "user": "root",
        "group": "root",
        "download_url": "http://storage.c4d.griddynamics.net/distr/genesis/distribution-gd-1.0.0-SNAPSHOT.tar.gz",
        "dirs_to_create": ["/opt/genesis/logs", "/opt/genesis/pids"],
        "app_name": "genesis",
        "start_cmdline": "-XX:MaxPermSize=256m -Dbackend.properties=file:$APP_HOME/genesis.properties -cp \"$APP_HOME/*\" com.griddynamics.genesis.GenesisFrontend",
        "stdout_log": "/opt/genesis/logs/stdout.log",
        "pid_file": "/opt/genesis/pids/genesis.pid",
        "config_file": "/opt/genesis/genesis.properties",
        "config_properties": {
            "genesis.plugin.chef.credential" : "file:/opt/genesis/keys/rsvato.pem",
            "genesis.plugin.chef.endpoint" : "https://api.opscode.com/organizations/gd",
            "genesis.plugin.chef.identity" : "rsvato",
            "genesis.plugin.chef.validator.credential" : "file:/opt/genesis/keys/gd-validator.pem",
            "genesis.plugin.chef.validator.identity" : "gd-validator",
    
            "genesis.chefsolo.privKey" : "/opt/genesis/demo-pack/resources/keys/id_rsa_mysvc",
            "genesis.chefsolo.pubKey" : "/opt/genesis/demo-pack/resources/keys/id_rsa_mysvc.pub",
            "genesis.chefsolo.resourcePath" : "/opt/genesis/demo-pack/resources",
            "genesis.plugin.chefsolo.cookbooks" : "/opt/genesis/demo-pack/resources/cookbooks.tar.gz",
            "genesis.plugin.chefsolo.templates" : "/opt/genesis/demo-pack/resources/jsons",
    
            "genesis.gdnova.key.pair" : "genesis-key",
    
            "genesis.plugin.jclouds.credential" : "320ba983-f835-42ae-bbbd-0d8d774b4020",
            "genesis.plugin.jclouds.endpoint" : "http://172.18.41.1:5000",
            "genesis.plugin.jclouds.identity" : "genesis:genesis",
            "genesis.plugin.jclouds.gdnova.vm.identity" : "root",
            "genesis.plugin.jclouds.gdnova.vm.credential" : "file:/opt/genesis/keys/cloud4gd.pem",
            "genesis.plugin.jclouds.provider" : "gdnova",
    
            "genesis.labmanager.createFakeEnv" : "false",
    
            "genesis.template.repository.fs.path" : "/opt/genesis/templates",
            "genesis.template.repository.mode" : "filesystem",
    
            "genesis.system.bind.port" : "8080",
            "genesis.system.jdbc.driver" : "org.h2.Driver",
            "genesis.system.jdbc.password" : "\"\"",
            "genesis.system.jdbc.url" : "jdbc:h2:file:~/genesis_db.h2",
            "genesis.system.jdbc.username" : "\"\"",
            "genesis.system.jdbc.drop.db" : false,
            "genesis.system.default.vm.identity" : "root",
            "genesis.system.default.credential" : "file:/opt/genesis/keys/cloud4gd.pem",
            "genesis.system.beat.period.ms" : 1000,
            "genesis.system.flow.timeout.ms" : 3600000,
            "genesis.system.web.client.cache" : false
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

