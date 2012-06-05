class Chef
    class Recipe
        # guess archive type by its URL
        def archiveTypeByUrl(url = "")
            if url.empty?
                return ""
            end
            if url.match(/\.zip$/)
                return "zip"
            elif url.match(/\.tar\.gz$/)
                return "tar.gz"
            else
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
