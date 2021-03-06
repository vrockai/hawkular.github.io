#!/bin/bash
#
# Copyright 2014-2015 Red Hat, Inc. and/or its affiliates
# and other contributors as indicated by the @author tags.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

addHeaders() {
  dir_path=$1

  for file in $(find $dir_path -maxdepth 1 -mindepth 1); do
    # it assumes the filenames to be in "rest-${component}.adoc" form

    title=`echo $(basename $file) | cut -d'.' -f1 | cut -d'-' -f2`
    title="$(tr '[:lower:]' '[:upper:]' <<< ${title:0:1})${title:1} REST API"
    echo $title

    HEADER="= $title\n\
Travis CI\n\
`date "+%Y-%m-%d"`\n\
:description: Auto-generated swagger documentation\n\
:icons: font\n\
:jbake-type: page\n\
:jbake-status: published\n\
:toc: macro\n\
:toc-title:\n\
\n\
toc::[]\n\
"
    # add the header
    sed -i.bak "1s;^;$HEADER;" $file
  done
}

downloadAndProcess() {
  REPO="hawkular/hawkular.github.io"
  BRANCH="swagger"
  DOC_PATH="src/main/jbake/content/docs/rest/"

  mkdir -p $DOC_PATH
  FILES=`curl -Ls https://api.github.com/repos/$REPO/contents/?ref=$BRANCH | grep "download_url.*adoc" | cut -d '"' -f4`
  for file in $FILES; do
    wget -P $DOC_PATH $file
  done
  addHeaders $DOC_PATH
  rm -f $DOC_PATH/*.bak
}

downloadAndProcess
