#! /usr/bin/env bash
#
#
#
set -ex

W=www.nwcg.gov

MYDIRS=(/committees/geospatial-subcommittee
        /publications/pms936
        /publications/pms936-1
        /sites/default/files/publications)
mydirs=$(IFS=,;echo "${MYDIRS[*]}")

main() {
    giss
}

giss() {

    # mirror the GISS-related content
    wget --no-verbose --execute robots=off --mirror \
      --adjust-extension --page-requisite --convert-links \
      --include-directories="$mydirs" \
      https://$W/committees/geospatial-subcommittee \
      https://$W/publications/pms936{,-1} ||:

    # remove non-essential dynamic elements
    htmlgroom 's/"theme_token":"[^"]+",//g'
    # and some more Drupal dynamic IDs used for Ajax pages
    htmlgroom 's/ view-dom-id-[^"]+//g'
    # and some // references inside js that wget can't convert
    htmlgroom "s|'(//siteimproveanalytics\.com)/|'https:\1/|g"
}

htmlgroom() {
    local inline="$1"
    find $w -type f -name '*.html' -print0 \
      |xargs -r0 sed -Ei "$inline"
}

main
exit 0
