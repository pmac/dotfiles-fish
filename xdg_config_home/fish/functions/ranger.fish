function ranger --wraps ranger --description 'runs local copy of ranger'
    if type -q ~/Projects/_Mirror/ranger/ranger.py
        ~/Projects/_Mirror/ranger/ranger.py $argv
    else
        ranger $argv
    end
end
