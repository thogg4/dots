function h --description 'Start herdr with a space for every directory in ~/work'
    # Creating spaces needs a running server, so start one headless first.
    if not herdr workspace list >/dev/null 2>&1
        herdr server >/dev/null 2>&1 </dev/null &
        disown
        for i in (seq 50)
            herdr workspace list >/dev/null 2>&1; and break
            sleep 0.1
        end
    end

    set list (herdr workspace list)
    or return 1
    set existing (string match -arg '"label"\s*:\s*"([^"]*)"' -- $list)

    for dir in ~/work/*/
        set name (path basename $dir)
        contains -- $name $existing
        or herdr workspace create --cwd $dir --label $name --no-focus >/dev/null
        or return 1
    end

    herdr
end
