#!/bin/bash
#
# retrieve.sh
#
# Author: Gerrit Riessen, gerrit@openmindmap.org
# Copyright (C) 2023 Gerrit Riessen
# This code is licensed under the GNU Public License.
#
# $Id$
#

# This script will retrieve certain configuration files from an existing
# node red instance and copy these here. It retrieves:
#
#   - icons configuration and all icons
#   - nodes configuration .json, .html and locales
#   - plugin configuration .json, .html and locales
#   - locales in the locales directory
#
# other things will need to be updated manually.

### TODO change the following.
NODERED_URL=http://node-red-instance-host:1880/httpAdminRoot

### TODO remove this also
echo "Edit retrieve.sh before use"
exit

CBSTMP=$(date +%s)
PyTHON=/usr/bin/python3

LoCaLeS="en-US en-GB en de-DE de fr ja ko pt-BR ru zh-CN zh-TW"

echo "==> icons.json"
curl -s "${NODERED_URL}/icons?_=${CBSTMP}" -H 'Accept: application/json' | $PyTHON .py/json_pretty.py > icons.json

for lnk in `cat icons.json | $PyTHON .py/icon_urls.py` ; do
    echo "==> ${lnk}"
    mkdir -p `dirname ${lnk}`
    curl -s ${NODERED_URL}/${lnk} > ${lnk}
done

for typ in nodes plugins ; do

    for lng in ${LoCaLeS} ; do
        echo "==> ${typ}/messages/${lng}"
        curl -s "${NODERED_URL}/${typ}/messages?lng=${lng}&_=${CBSTMP}" | $PyTHON .py/json_pretty.py > ${typ}/messages.${lng}
    done
    cp ${typ}/messages.en-US ${typ}/messages

    echo "==> ${typ}/nodes.json"
    curl -s "${NODERED_URL}/${typ}?_=${CBSTMP}" -H 'Accept: application/json' | $PyTHON .py/json_pretty.py > ${typ}/${typ}.json

    echo "==> ${typ}/nodes.html"
    curl -s "${NODERED_URL}/${typ}?_=${CBSTMP}" -H 'Accept: text/html' > ${typ}/${typ}.html

done

for lcls in editor infotips node-red jsonata ; do
    for lng in ${LoCaLeS} ; do
        echo "==> locales/${lcls}/${lng}"
        curl -s "${NODERED_URL}/locales/${lcls}?lng=${lng}" | $PyTHON .py/json_pretty.py > locales/${lcls}.${lng}
    done
done

for lnk in FlowHubLib/jslib/diff.min.js \
           FlowCompare/jslib/flowviewer.min.js \
           FlowCompare/jslib/diff.min.js \
           ; do

    echo "==> ${lnk}"
    mkdir -p `dirname ${lnk}`
    curl -s ${NODERED_URL}/${lnk} > ${lnk}
done
