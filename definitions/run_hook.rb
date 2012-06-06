define :run_hook, :script_url => "" do
    # if the script is defined
    if ! params[:script_url].empty?
        # prepare an empty directory for the script
        require 'tmpdir'
        script_tmp_dir = Dir.mktmpdir
        script_file_name = filenameByUrl(params[:script_url])

        # download the script
        remote_file "#{script_tmp_dir}/#{script_file_name}" do
            source params[:script_url]
            mode "0755"
            backup false
            action :create
        end

        # run the script
        execute "#{script_tmp_dir}/#{script_file_name}" do
           action :run
        end

        # clean-up
        directory "#{script_tmp_dir}" do
            action :delete
            recursive true
        end
    end
end
