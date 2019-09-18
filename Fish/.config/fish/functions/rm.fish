function rm
	set -l params -i

	if test (uname -s) = 'Linux'
		set params $params --preserve-root
	end

	command rm $params $argv
end
