#!/bin/bash
set -e

rm -f Procfile
# Allow docker-gen to be disabled
if [[ ${DISABLE_DOCKER_GEN} != "true"  ]]; then
	# Warn if the DOCKER_HOST socket does not exist
	if [[ $DOCKER_HOST = unix://* ]]; then
		socket_file=${DOCKER_HOST#unix://}
		if ! [ -S $socket_file ]; then
			cat >&2 <<-EOT
				ERROR: you need to share your Docker host socket with a volume at $socket_file
				Typically you should run your jwilder/nginx-proxy with: \`-v /var/run/docker.sock:$socket_file:ro\`
				See the documentation at http://git.io/vZaGJ
			EOT
			socketMissing=1
		fi
	fi

	# If the user has run the default command and the socket doesn't exist, fail
	if [ "$socketMissing" = 1 -a "$1" = forego -a "$2" = start -a "$3" = '-r' ]; then
		exit 1
	fi

	echo 'dockergen: docker-gen -watch -notify "nginx -s reload" /app/nginx.tmpl /etc/nginx/conf.d/default.conf' >> Procfile
fi

echo 'nginx: nginx' >> Procfile

forego start -r