function mts
    set current_branch (git rev-parse --abbrev-ref HEAD)
    if test $status -ne 0
        echo "Not in a git repository"
        return 1
    end

    echo "Merging $current_branch into stage..."
    git checkout stage && git merge $current_branch && git push
    set merge_status $status
    git checkout $current_branch
    return $merge_status
end
