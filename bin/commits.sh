#!/bin/bash

# commits.sh

# VIS3 kehtestuste nädalaaruanne

# Skript võtab igast ecyber koodirepost 60 viimast kehtestust (commit), sorteerib need ja väljastab
# ühtse loeteluna viimase nädala jooksul tehtud kehtestused. Kehtestuse kohta näidatakse kuupäev,
# kehtestaja, repo ja kehtestusteade (commit message).
# Aruanne ei hõlma mestimiskehtestusi.
# Skriptil ei ole tõenäoliselt erilist juhtimisväärtust, kuid demonstreerib Bitbucket API võimalusi.

# Eeldused: Nõuab jq olemasolu täitmismasinas (sudo apt-get install jq)
# Kasutamine: Täida skript RIA sisevõrgus, Ubuntu masinas.

# Infoturve: Skript sisaldab RIA sisemisi nimesid ja Bitbucket VIS3 API salasõna (lugemisõigus).
# Seetõttu skript ei ole avalikustamiseks.

# Priit Parmakson, 14.10.2020

Last_week=$(date --date='7 days ago' +%s%3N)
Seitse_p_tagasi=$(date --date='7 days ago' --rfc-email)
echo "ECYBER kehtestuste nädalaaruanne"
echo "Kehtestused ECYBER repodes nädala jooksul, alates $Seitse_p_tagasi"
echo ""

for repo in \
  'ecyber-cms' 'ecyber-wordpress'; do
  curl --silent \
    --user toomasm \
    --insecure "https://stash.ria.ee/rest/api/latest/projects/ecyber/repos/$repo/commits?merges=exclude&&limit=60" # | \
    # jq ".values[] | { ts: .committerTimestamp, kp: .committerTimestamp | (. / 1000 | strftime(\"%d.%m.%Y\")),  committer: .committer.name, repo: \"$repo\", msg: .message }"
done # | \
# jq --slurp '.' | \
# jq "map(select(.ts >= $Last_week))" | \
# jq 'sort_by(- .ts) | .[]' | \
# jq --compact-output '{ kp: .kp, committer: .committer, repo: .repo, msg: .msg }'

# Märkmed
# https://serverfault.com/questions/151109/how-do-i-get-the-current-unix-time-in-milliseconds-in-bash/151112

# https://remysharp.com/drafts/jq-recipes

# https://www.gnu.org/software/coreutils/manual/html_node/Examples-of-date.html
