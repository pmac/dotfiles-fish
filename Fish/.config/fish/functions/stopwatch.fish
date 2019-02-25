function stopwatch --description 'Start counting time'
	set -l t0 (date -u +%s)
	while true
		set -l t1 (date -u +%s)
		echo -n (date -u --date=@(math $t1 - $t0) +%H:%M:%S\r)
		sleep 0.1
	end
end
