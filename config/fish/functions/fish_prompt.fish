function fish_prompt
    set -l last_status $status

    set -l char ❯
    set -l char_color $theme_green
    switch $fish_bind_mode
        case default
            set char ❮
        case replace replace_one
            set char ❮
            set char_color $theme_violet
        case visual
            set char ❮
            set char_color $theme_yellow
        case '*'
            test $last_status -ne 0; and set char_color $theme_red
    end

    if contains -- --final-rendering $argv
        set_color $theme_comment
        echo -n (date +%H:%M)' '
        set_color -o $char_color
        echo -n $char
        set_color normal
        echo -n ' '
        return
    end

    set -l repo_root
    set -l dir $PWD
    while true
        if test -e $dir/.git
            set repo_root $dir
            break
        end
        test $dir = /; and break
        set dir (path dirname $dir)
    end

    set -l shown (string replace -r -- "^$HOME(?=/|\$)" '~' $PWD)
    if test -n "$repo_root"; and test $repo_root != $HOME
        set shown …/(path basename $repo_root)(string sub -s (math (string length -- $repo_root) + 1) -- $PWD)
    end
    set -l parts (string split / -- $shown)
    if test (count $parts) -gt 3
        set shown …/(string join / -- $parts[-3..-1])
    end
    for sub in Documents:\U000f0219 Downloads: Music:\U000f075a Pictures: Developer:\U000f0c8b
        set -l kv (string split : -- $sub)
        set shown (string replace -a -- $kv[1] "$kv[2] " $shown)
    end

    set -l branch
    set -l stash
    if test -n "$repo_root"
        set -l git_dir $repo_root/.git
        if test -f $git_dir
            read -l line <$git_dir
            set git_dir (string replace 'gitdir: ' '' -- $line)
            string match -q '/*' -- $git_dir; or set git_dir $repo_root/$git_dir
        end
        set -l common_dir $git_dir
        if test -f $git_dir/commondir
            read common_dir <$git_dir/commondir
            string match -q '/*' -- $common_dir; or set common_dir $git_dir/$common_dir
        end

        read -l head <$git_dir/HEAD
        if string match -q 'ref: refs/heads/*' -- $head
            set branch (string sub -s 17 -- $head)
        else
            set branch (string sub -l 7 -- $head)
        end
        test -e $common_dir/logs/refs/stash; and set stash '$ '
    end

    set -l duration
    if test "$CMD_DURATION" -ge 2000
        set -l ms $CMD_DURATION
        set duration (string join '' (math "floor($ms / 86400000)")d (math "floor($ms / 3600000) % 24")h (math "floor($ms / 60000) % 60")m (math "floor($ms / 1000) % 60")s | string replace -r '^(0[dhm])+' '')(math $ms % 1000)ms
    end

    set -l clock "  "(date +%H:%M)" "
    set -l git
    for step in clock dir branch done
        test -n "$branch"; and set git "  $branch $stash"
        test (math (string length --visible -- "$shown$git$clock$duration") + 26) -le $COLUMNS; and break
        switch $step
            case clock
                set clock
            case dir
                set shown (path basename -- $PWD)
            case branch
                set branch (string shorten -m 16 -- $branch)
        end
    end

    set_color $theme_red
    echo -n 
    set_color -b $theme_red $theme_bgDark
    echo -n \U000f0035
    set_color -b $theme_orange $theme_red
    echo -n 
    set_color -b $theme_orange $theme_bgDark
    echo -n " $shown "
    set_color -b $theme_yellow $theme_orange
    echo -n 
    set_color -b $theme_yellow $theme_bgDark
    echo -n $git
    set_color -b $theme_green $theme_yellow
    echo -n 
    set_color -b $theme_violet $theme_green
    echo -n 
    set_color -b $theme_violet $theme_bgDark
    echo -n $clock
    set_color normal
    set_color $theme_violet
    echo -n ' '
    set_color normal
    test -n "$duration"; and echo -n " in $duration "
    set_color -o $char_color
    echo -n $char
    set_color normal
    echo -n ' '
end
