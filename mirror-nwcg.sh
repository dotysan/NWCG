#! /usr/bin/env bash
#
#
#
set -ex

W=www.nwcg.gov

MYDIRS=(/committees/geospatial-subcommittee
        /publications/position-taskbooks/311-77
        /publications/pms936
        /publications/pms936-1
        /publications/ics-forms
        /sites/default/files/stds
        /sites/default/files/products
        /sites/default/files/publications
        /data-standards/approved
        /EMIWeb/IS/ICSResource/assets) # last one is on fema.gov
mydirs=$(IFS=,;echo "${MYDIRS[*]}")

main() {
    giss
    fema
    git diff --word-diff=porcelain
}

giss() {

    # mirror the GISS-related content
    wget --no-verbose --execute robots=off --mirror \
      --span-hosts --domains='www.nwcg.gov,training.fema.gov' \
      --adjust-extension --page-requisite --convert-links \
      --include-directories="$mydirs" \
      https://$W/committees/geospatial-subcommittee \
      https://$W/data-standards-approved/geospatial-data-layer \
      https://$W/publications/position-taskbooks/311-77 \
      https://$W/publications/{pms936{,-1},ics-forms} ||:

    # remove non-essential dynamic elements
    htmlgroom 's/"theme_token":"[^"]+",//g'
    # and some more Drupal dynamic IDs used for Ajax pages
    htmlgroom 's/ view-dom-id-[^"]+//g'
    # and some // references inside js that wget can't convert
    htmlgroom "s|'(//siteimproveanalytics\.com)/|'https:\1/|g"
    # these html tags appear to change periodically too
    htmlgroom 's/\.(css|js)\?[^"]+"/.\1"/g'
}

fema() {
    wget --no-verbose --execute robots=off --mirror \
      --adjust-extension --page-requisite --convert-links \
      --include-directories=/EMIWeb/IS/ICSResource/assets \
      https://training.fema.gov/emiweb/is/icsresource/icsforms/
}

htmlgroom() {
    local inline="$1"
    find $w -type f -name '*.html' -print0 \
      |xargs -r0 sed -Ei "$inline"
}

main
exit 0
