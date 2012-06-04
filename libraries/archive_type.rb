class Chef
    class Recipe
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
