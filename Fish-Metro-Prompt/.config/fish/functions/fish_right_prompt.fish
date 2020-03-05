function fish_right_prompt
    set -l status_color 555
    set -l status_txt ""
    if test "$CMD_DURATION" -gt 250
        set -l duration (echo $CMD_DURATION | humanize_duration)
        set status_txt "($duration) | "
    end

    echo -sn (set_color $status_color){$status_txt}(date "+%b %d, %H:%M:%S")(set_color normal)
end
