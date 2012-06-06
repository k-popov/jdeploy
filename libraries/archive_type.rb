class Chef
    class Recipe
        # guess archive type by its URL
        def archiveTypeByUrl(url = "")
            if url.empty?
                return ""
            end
            if url.match(/\.zip$/)
                Chef::Log.info "Detected archive type: zip"
                return "zip"
            elsif url.match(/\.tar\.gz$/)
                Chef::Log.info "Detected archive type: tar.gz"
                return "tar.gz"
            else
                Chef::Log.info "Detected archive type: <empty>"
                return ""
            end
        end

        # generate the file name by its URL
        def filenameByUrl(url = "")
            filename = url.split('/')[-1]
            if ! filename
                return "app_archive.unknown"
            else
                return filename
            end
        end
    end
end
