#!/usr/bin/env bash
#
# update-golang is a script to easily fetch and install new Golang releases
#
# Home: https://github.com/udhos/update-golang
#
# PIPETHIS_AUTHOR udhos

# ignore runtime environment variables
# shellcheck disable=SC2153
version=0.28

set -o pipefail

me=$(basename "$0")
msg() {
    echo >&2 "$me: $*"
}

debug() {
    [ -n "$DEBUG" ] && msg "debug: $*"
}

log_stdin() {
    while read -r i; do
        msg "$i"
    done
}
# defaults
release_list=https://go.dev/dl/
source=https://storage.googleapis.com/golang
#source=https://dl.google.com/go
#source=https://go.dev/dl
destination=/usr/local
release=1.24.0 # just the default. the script detects the latest available release.
arch_probe="uname -m"
connect_timeout=5
os=$(uname -s | tr "[:upper:]" "[:lower:]")

if [ -d /etc/profile.d ]; then
    profiled=/etc/profile.d/golang_path.sh
else
    profiled=/etc/profile
fi

[ -n "$ARCH_PROBE" ] && arch_probe="$ARCH_PROBE"
arch=$($arch_probe)
case "$arch" in
    i*)
        arch=386
        ;;
    x*)
        arch=amd64
        ;;
    aarch64)
        arch=arm64
        ;;
    armv7l)
        msg armv7l is not supported, using armv6l
        arch=armv6l
        ;;
esac

show_version() {
    msg version "$version"
}

# avoid trying 1.12beta because 1.12beta1 is valid while 1.12beta is not
# if you want beta, force RELEASE=1.12beta1
exclude_beta() {
    grep -v -E 'go[0-9\.]+beta|rc'
}

scan_versions() {
    local fetch="$1"
    debug scan_versions: from "$release_list"
    if has_cmd jq; then
        local rl="$release_list?mode=json"
        msg "scan_versions: fetch: $fetch $rl"
        msg "scan_versions: parsing with jq from $rl"
        $fetch "$rl" | jq -r '.[].files[].version' | sort | uniq | exclude_beta | sed -e 's/go//' | sort -V
    else
        $fetch "$release_list" | exclude_beta | grep -E -o 'go[0-9\.]+' | grep -E -o '[0-9]\.[0-9]+(\.[0-9]+)?' | sort -V | uniq
    fi
}

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

has_wget() {
    [ -z "$SKIP_WGET" ] && has_cmd wget
}

has_curl() {
    has_cmd curl
}

tmp='' ;# will be set
save_dir=$PWD
previous_install='' ;# will be set
declutter='' ;# will be set
tar_to_remove='' ;# will be set
cleanup() {
    [ -n "$tmp" ] && [ -f "$tmp" ] && msg cleanup: "$tmp" && rm "$tmp"
    [ -n "$declutter" ] && [ -n "$tar_to_remove" ] && [ -f "$tar_to_remove" ] && msg cleanup: "$tar_to_remove" && rm "$tar_to_remove"
    [ -n "$save_dir" ] && cd "$save_dir" || exit 2
    [ -n "$previous_install" ] && msg remember to delete previous install saved as: "$previous_install"
}

die() {
    msg "die: $*"
    cleanup
    exit 3
}

wget_base() {
    echo wget --connect-timeout "$connect_timeout" "$FORCE_IPV4"
}

curl_base() {
    echo curl --connect-timeout "$connect_timeout" "$FORCE_IPV4"
}

find_latest() {
    debug find_latest: built-in version: "$release"
    debug "find_latest: from $release_list"
    local last=
    local fetch=
    if has_wget; then
        fetch="$(wget_base) -qO-"
    elif has_curl; then
        fetch="$(curl_base) --silent"
    else
        die "find_latest: missing both 'wget' and 'curl'"
    fi
    last=$(scan_versions "$fetch" | tail -1)
    if echo "$last" | grep -q -E '[0-9]\.[0-9]+(\.[0-9]+)?'; then
        msg find_latest: found last release: "$last"
        release=$last
    else
        msg find_latest: FAILED
    fi
}

[ -n "$RELEASE_LIST" ] && release_list=$RELEASE_LIST

if [ -n "$RELEASE" ]; then
    msg release forced to RELEASE="$RELEASE"
    release="$RELEASE"
else
    find_latest
fi

[ -n "$SOURCE" ] && source=$SOURCE
[ -n "$DESTINATION" ] && destination=$DESTINATION
[ -n "$OS" ] && os=$OS
[ -n "$ARCH" ] && arch=$ARCH
cache=$destination
[ -n "$CACHE" ] && cache=$CACHE
[ -n "$PROFILED" ] && profiled=$PROFILED
[ -n "$CONNECT_TIMEOUT" ] && connect_timeout=$CONNECT_TIMEOUT
show_vars() {
    echo "user: $(id)"

    cat <<EOF

RELEASE_LIST=$release_list
SOURCE=$source
DESTINATION=$destination
RELEASE=$release
OS=$os
ARCH_PROBE=$arch_probe
ARCH=$arch
PROFILED=$profiled
CACHE=$cache
GOPATH=$GOPATH
DEBUG=$DEBUG
FORCE_IPV4=$FORCE_IPV4           ;# set FORCE_IPV4=-4 to force IPv4
CONNECT_TIMEOUT=$connect_timeout
SKIP_WGET=$SKIP_WGET             ;# set SKIP_WGET=1 to skip wget

EOF
}

label=go$release.$os-$arch
filename=$label.tar.gz
url=$source/$filename
goroot=$destination/go
filepath=$cache/$filename
new_install=$destination/$label

solve() {
    local path=$1
    local p=
    if echo "$path" | grep -E -q ^/; then
        p="$path"
        local m=
        m=$(file "$p" 2>/dev/null)
        debug "solve: $p: $m"
    else
        p="$save_dir/$path"
    fi
    echo "$p"
}
abs_filepath=$(solve "$filepath")
abs_url=$(solve "$url")
abs_goroot=$(solve "$goroot")
abs_new_install=$(solve "$new_install")
abs_gobin=$abs_goroot/bin
abs_gotool=$abs_gobin/go
abs_profiled=$(solve "$profiled")

download() {
    if echo "$url" | grep -E -q '^https?:'; then
        msg "$url" is remote
        if [ -f "$abs_filepath" ]; then
    msg "no need to download - file cached: $abs_filepath"
else
    if has_wget; then
        msg "download: $(wget_base) -O $abs_filepath $url"
        $(wget_base) -O "$abs_filepath" "$url" || die "could not download using wget from: $url"
        [ -f "$abs_filepath" ] || die "missing file downloaded with wget: $abs_filepath"
    elif has_curl; then
        msg "download: $(curl_base) -o $abs_filepath $url"
                $(curl_base) -o "$abs_filepath" "$url" || die could not download using curl from: "$url"
                [ -f "$abs_filepath" ] || die missing file downloaded with curl: "$abs_filepath"
            else
                die "download: missing both 'wget' and 'curl'"
            fi
        fi
    else
        msg "$abs_url" is local
        cp "$abs_url" . || die could not copy from: "$abs_url"
    fi
}

symlink_test() {
    readlink "$1" >/dev/null 2>&1
}

symlink_get() {
    readlink "$1"
}

symlink_set() {
    local target=$1
    local symlink=$2
    if [ -L "$symlink" ]; then
        msg updating symlink: "$symlink" '->' "$target"
        ln -sf "$target" "$symlink" || die could not update symlink: "$symlink"
        return
    fi
    if [ -d "$symlink" ]; then
        local backup="$symlink.backup.$$"
        msg moving existing directory: "$symlink" to: "$backup"
        mv "$symlink" "$backup" || die could not move existing directory: "$symlink" to: "$backup"
        previous_install=$backup
    fi
    if [ -f "$symlink" ]; then
        local backup="$symlink.backup.$$"
        msg moving existing file: "$symlink" to: "$backup"
        mv "$symlink" "$backup" || die could not move existing file: "$symlink" to: "$backup"
        previous_install=$backup
    fi
    msg creating symlink: "$symlink" '->' "$target"
    ln -sf "$target" "$symlink" || die could not create symlink: "$symlink"
}

[ -d "$cache" ] || mkdir -p "$cache" || die "could not create cache dir: $cache"

show_vars
download

declutter=1
tar_to_remove=$filename

msg extracting "$filename"
tar xf "$filename" || die "could not extract: $filename"

msg installing go"$release" to "$abs_new_install"
rm -rf "$abs_new_install" ;# try to remove old extract
mv go "$abs_new_install" || die "could not move 'go' to: $abs_new_install"

msg updating symlink: "$abs_goroot" '->' "$abs_new_install"
symlink_set "$abs_new_install" "$abs_goroot" || die "could not update symlink: $abs_goroot"

profile_path() {
    local prof=$1
    grep -E '^[^#]*PATH=.*GOROOT' "$prof" >/dev/null 2>&1
}

profile_gopath() {
    local prof=$1
    grep -E '^[^#]*GOPATH=' "$prof" >/dev/null 2>&1
}

profile_home() {
    local prof=$1
    grep -E '^[^#]*GOROOT=' "$prof" >/dev/null 2>&1
}

msg checking profile: "$abs_profiled"

if ! profile_home "$abs_profiled"; then
    msg setup GOROOT in: "$abs_profiled"
    echo export GOROOT=\"$abs_goroot\" >> "$abs_profiled"
fi

if ! profile_path "$abs_profiled"; then
    msg setup PATH in: "$abs_profiled"
    echo export PATH=\"'$abs_goroot/bin:$PATH'\" >> "$abs_profiled"
fi

if ! profile_gopath "$abs_profiled" && [ -z "$GOPATH" ]; then
    msg setup GOPATH in: "$abs_profiled"
    echo export GOPATH=\"'$HOME/go'\" >> "$abs_profiled"
fi

# self test
msg "running self test ($abs_gotool version)"
"$abs_gotool" version || die failed self test

cleanup

msg success