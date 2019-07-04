#!/bin/bash
set -eu
curl https://cli-assets.heroku.com/install.sh | sh
cat > ~/.netrc << EOF
machine api.heroku.com
login $HEROKU_LOGIN
password $HEROKU_API_KEY
machine git.heroku.com
login $HEROKU_LOGIN
password $HEROKU_API_KEY
EOF
chmod 600 ~/.netrc
