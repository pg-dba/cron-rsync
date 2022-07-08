#!/bin/bash

host="${1}"

if [ -z "${host}" ]; then
    echo "No argument given. Exiting."
    exit
elif [ ! -s "${host}/host" ]; then
    echo "Host '${host}' cannot be found at ${host}/host. Exiting."
    exit
fi

full_host=$(<"${host}/host")
current_fingerprint=$(<"${host}/fingerprint")
echo "Getting LIVE fingerprint for '${host}' ($full_host)..."
fingerprint=$(ssh-keyscan -4 -T 5 -t rsa -f "${host}/host" 2>&1)

if diff -q <(echo "$fingerprint") <(echo "$current_fingerprint"); then
    echo "The live fingerprint for '${host}' is the SAME as ${host}/fingerprint."
else
    echo "The live fingerprint has CHANGED:"
    echo "$fingerprint"
    read -p "Accept updated fingerprint? (y/n) " -n 1 -r
    echo
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        echo "Updating saved fingerprint..."
        mv "${host}/fingerprint" "${host}/fingerprint.bak"
        sleep 0.5
        echo "$fingerprint" > "${host}/fingerprint"
        echo "Done. Saved old fingerprint as ${host}/fingerprint.bak."
    else
        echo "Exiting with no changes."
    fi
fi
