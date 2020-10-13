function curl-follow --description 'Follow redirects with curl'
    curl -ILgs $argv | grep -ie "^location" -e "^HTTP"
end
