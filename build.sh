#!/usr/bin/env bash
set -Eeuo pipefail

function show_help {
  echo """
  Build Alpine or Debian Based CKAN Image

  Usage:
    ./build.sh [options]

  Options:
    --deb         | -d      build Debain image.
    --dry-run               performs a dry-run to show configs.
    --help        | -h      show this message.
    --namespace             docker hub account name.
    --no-cache              build image without using cache.
    --tag         | -t      the image tag.
  """
}

function _build_image_name {
  local deb=$1
  local namespace=$2
  local tag=$3

  local image_name="${namespace}/ckan:${tag}"
  if [[ ${deb} = "no" ]]; then
    image_name="${image_name}-alpine"
  fi

  result=${image_name}
}

function build {
  local deb=$1
  local image_name=$2
  local nocache=$3
  local filename=Dockerfile

  if [[ ${deb} = "yes" ]]; then
    filename=Dockerfile.deb
  fi

  echo ">> Building CKAN Image '${image_name}' (using ${filename}) ..."
  echo ""

  if [[ ${nocache} = "yes" ]]; then
    docker build -f rootfs/${filename} -t ${image_name} rootfs
  else
    docker build --no-cache -f rootfs/${filename} -t ${image_name} rootfs
  fi
}

deb=no
dry_run=no
nocache=no
namespace=${DOCKERHUB_NAMESPACE:=hazeltek}
version=$(git describe --tags --exact-match 2>/dev/null || echo latest)

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d | --deb )
      deb=yes
      shift
    ;;

    --dry-run )
      dry_run=yes
      shift
    ;;

    --namespace )
      shift
      namespace=$1
      shift
    ;;

    --no-cache )
      nocache=yes
      shift
    ;;

    -h | --help )
      show_help
      exit 0
    ;;

    -t | --tag )
      shift
      version=$1
      shift
    ;;
  esac
done

# build image name which is stored in global var: result
_build_image_name ${deb} ${namespace} ${version}

if [[ $dry_run = "yes" ]]; then
  echo "deb=${deb} namespace=${namespace} tag=${version}"
  echo ${result}
else
  build ${deb} ${result} ${nocache}
fi
