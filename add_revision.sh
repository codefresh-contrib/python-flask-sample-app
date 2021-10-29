#!/bin/bash
# flaskr/templates/base.html

revision=$( sed -n 's/.*Revision \([0-9]\+\).*/\1/p' flaskr/templates/base.html )
(( revision++ ))
echo "$revision"

new_revision=revision-0$revision
git checkout -b ${new_revision}
sed -i.bak '/Revision/ s/ \([0-9]\+\)/ '$revision'/' flaskr/templates/base.html

git commit -a -m "$revision"
git push --set-upstream origin ${new_revision}
