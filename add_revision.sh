#!/bin/bash
# flaskr/templates/base.html

revision=$( sed -n 's/.*Revision \([0-9]\+\).*/\1/p' flaskr/templates/base.html )
(( revision++ ))
echo "$revision"
sed -i.bak '/Revision/ s/ \([0-9]\+\)/ '$revision'/' flaskr/templates/base.html

git commit -a -m "$revision"
