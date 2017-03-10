#!/bin/bash

set -e

PLUGIN_TXT=${PLUGIN_TXT:-/usr/share/elasticsearch/plugins.txt}

while [ ! -f "/usr/share/elasticsearch/config/elasticsearch.yml" ]; do
    sleep 1
done

if [ -f "$PLUGIN_TXT" ]; then
    for plugin in $(<"${PLUGIN_TXT}"); do
        /usr/share/elasticsearch/bin/plugin --install $plugin
    done
fi

# plugins are space separated, example: PLUGINS=mobz/elasticsearch-head appbaseio/dejavu cloud-aws
if [ -n "$PLUGINS" ] ; then
	PLUGINZ=(${PLUGINS})

	for plugin in "${PLUGINZ[@]}"; do
		pluginpath=${plugin##*/}
		pluginpath="${pluginpath/elasticsearch-/}"

		if [ ! -d "/usr/share/elasticsearch/plugins/$pluginpath" ] ; then
			/usr/share/elasticsearch/bin/plugin install $plugin
		fi
	done
fi


exec /docker-entrypoint.sh elasticsearch
