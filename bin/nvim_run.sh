#!/bin/bash

CODING_DIR="${NVIM_RUN_CODING_DIR:-/home/mihira/c}"

# This function evaulates header commands in the
# file. Structure must be like :
# # VIMTRUN#!
# # <command>
# # VIMTRUN#!
eval_header () {
  IFS=$'\n'
  arr=($(sed -n /'#'/p "$1"))
  run=0
  for i in ${arr[@]}; do
    c=$(echo $i | sed s/'# '//g)
    if [ "$c" == "VIMTRUN#!" ]; then
      if [ "$run" -eq 1 ]; then
        break
      else
        run=1;
      fi
    else
      if [ $run -eq 1 ]; then
        eval $c
      fi
    fi
  done
  unset IFS
}


# This function evaulates header commands in the
# file. Structure must be like :
# // VIMTRUN#!
# // <command>
# // VIMTRUN#!
eval_header_fs () {
  IFS=$'\n'
  arr=($(sed -n /'\/\/'/p "$1"))
  run=0
  for i in ${arr[@]}; do
    c=$(echo $i | sed s/'\/\/ '//g)
    if [ "$c" == "VIMTRUN#!" ]; then
      if [ "$run" -eq 1 ]; then
        break
      else
        run=1;
      fi
    else
      if [ $run -eq 1 ]; then
        eval $c
      fi
    fi
  done
  unset IFS
}

# Check if file has // VIMTRUN~#! like headers
has_header_fs () {
  IFS=$'\n'
  arr=($(sed -n /'\/\/ VIMTRUN#!'/p "$1"))
  if [ ${#arr[@]} -ne 0 ]; then
    has_header_fs_res=1
  else
    has_header_fs_res=0
  fi
  unset IFS
}


if [ $(echo "$PWD" | grep "$CODING_DIR" -c) -eq '0' ]; then
  echo 'This script only works in the coding directory'
  exit
fi

# Determine what kind of file
type=$(echo "$1" | sed -r 's/(.*)(\.rs|\.py|\.java|\.js|\.sh|\.go|\.ts)/\2/g')

########################################################################
# Bash run script
########################################################################
if [ "$type" == '.sh' ]; then
  base_file_path=$(echo "$1" | sed 's/\/\w\+\.sh//g')
  buildName=$(echo "$base_file_path" | sed 's/.*\/\(\w\+.sh\)/\1/g')
  parentdir="$(dirname "$base_file_path")"
  exe_name=$(echo "$1" | sed 's/\.sh//g' | sed 's/\/.*\///g')
  (cd $parentdir; ./"$exe_name.sh")
  exit 0
fi

########################################################################
# Javascript
########################################################################
if [ "$type" == '.js' ]; then
  base_file_path=$(echo "$1" | sed 's/\/\w\+\.js//g')
  exe_name=$(echo "$1" | sed 's/\.js//g' | sed 's/\/.*\///g')
  ( cd $base_file_path;
    eval_header_fs "$exe_name.js";
    # node "$exe_name.js";
  )
  exit 0
fi

########################################################################
# Tyepscript
########################################################################
if [ "$type" == '.ts' ]; then
  base_file_path=$(echo "$1" | sed 's/\/\w\+\.ts//g')
  filepath="$1"
  exe_name=$(echo "$1" | sed 's/\.ts//g' | sed 's/\/.*\///g')

  has_header_fs "$filepath"
  if [ $has_header_fs_res -eq 1 ]; then
    eval_header_fs "$filepath"
  else
    ( cd $base_file_path;
      eval_header_fs "$exe_name.ts";
      if [ -d /tmp/tscOut/ ]; then rm -Rf /tmp/tscOut; fi
      mkdir -p /tmp/tscOut
      echo "Transpiling ......"
      tsc --outDir /tmp/tscOut "$exe_name".ts;
      echo ""
      NODE_PATH="$base_file_path/node_modules" node /tmp/tscOut/"$exe_name.js"
    )
  fi
  exit 0
fi

########################################################################
# Python run script
########################################################################
if [ "$type" == '.py' ]; then
  base_file_path=$(echo "$1" | sed 's/\/\w\+\.py//g')
  exe_name=$(echo "$1" | sed 's/\.py//g' | sed 's/\/.*\///g')
  ( cd $base_file_path;
    echo "Running : $base_file_path/$exe_name.py";
    echo "";
    eval_header "$exe_name.py";
    echo current env is $VIRTUAL_ENV
    # ./"$exe_name.py"
  )
  exit 0
fi

########################################################################
# Rust run
########################################################################
if [ "$type" == '.rs' ]; then
  # First check if custom run script exists
  path=$(echo "$1" | sed 's/\/\w\+\.rs//g')
  run_script_found='0'
  while [[ $path != "$CODING_DIR" ]];
  do
    if [[ -n $(find "$path" -maxdepth 1 -mindepth 1 -name 'nvim_run_script.sh' | head -n 1) ]]; then
      run_script_found='1'
      break
    fi
    path="$(dirname "$path")"
    # Sanity check
    if [[ $path == / ]];then break; fi
  done

  if [ "$run_script_found" -eq '1' ]; then
    (cd $path; ./nvim_run_script.sh)
    exit 0
  fi

  # Check if cargo exist in any of the parent directories
  # up until CODING DIR
  path=$(echo "$1" | sed 's/\/\w\+\.rs//g')
  cargoFound='0'
  while [[ $path != "$CODING_DIR" ]];
  do
    if [[ -n $(find "$path" -maxdepth 1 -mindepth 1 -name 'Cargo.toml' | head -n 1) ]]; then
      cargoFound='1'
      break
    fi
    path="$(dirname "$path")"
    # Sanity check
    if [[ $path == / ]];then break; fi
  done

  if [ "$cargoFound" -eq '1' ]; then
    (cd $path; RUST_BACKTRACE=1 cargo run)
  else
    if [ $(echo "$1" | grep -c "$CODING_DIR/c/rust_ex") -eq '1' ]; then
      # Special case of in ~/c/rust_ex we want all to compile to ~/c/rust_ex/target
      base_path="$CODING_DIR/c/rust_ex/target/"
      exe_name=$(echo "$1" | sed 's/\.rs//g' | sed 's/\/.*\///g')
      if [ -e "$base_path$exe_name" ]; then
        rm "$base_path$exe_name"
      fi

      $(rustc $1 --out-dir "$base_path")
      if [ $? -eq 0 ]; then
        "$base_path$exe_name"
      fi
    else
      # When the rust file is not located inside ~/c/rust_ex/
      base_path="$(echo "$1" | sed 's/\/\w\+\.rs//g')/target/"
      if [ ! -e "$base_path" ]; then
        mkdir "$base_path"
      fi
      exe_name=$(echo "$1" | sed 's/\.rs//g' | sed 's/\/.*\///g')
      if [ -e "$base_path$exe_name" ]; then
        rm "$base_path$exe_name"
      fi

      $(rustc $1 --out-dir "$base_path")
      if [ $? -eq 0 ]; then
        "$base_path$exe_name"
      fi
    fi
  fi
fi

########################################################################
# Golang
########################################################################
function gotmpcleanup {
  rm -r "$GO_TMP_DIR";
  echo "Deleted temp working directory $GO_TMP_DIR"
}

if [ "$type" == '.go' ]; then
  # Check if a src directory exists
  # up until $GOPATH
  filepath="$1"
  # path is the path to file which the script was run on
  path=$(echo "$filepath" | sed 's/\/\w\+\.go//g')
  # buildName is the directory containing the go file
  # go install will by default compile to a exec with name buildName
  buildName=$(echo "$path" | sed 's/.*\/\(\w\+\)/\1/g')
  runFound='1'
  if [ "$runFound" -eq '1' ]; then
    ( cd $path;
      echo $path;
      bin_name=$(go list);
      if [ $? -eq 0 ]; then
        has_header_fs "$filepath"
        if [ $has_header_fs_res -eq 1 ]; then
          eval_header_fs "$filepath"
        else
          GO_TMP_DIR=$(mktemp -d -p /tmp)
          trap gotmpcleanup EXIT
          go build -o "$GO_TMP_DIR/$bin_name"
          "$GO_TMP_DIR/$bin_name"
        fi
      else
        echo "Build failure";
      fi
    )
  else
    echo "Could not find go package"
  fi
fi

########################################################################
# Java
########################################################################
if [ "$type" == '.java' ]; then
  # Check if pom files exists
  # up until CODING_DIR
  path=$(echo "$1" | sed 's/\/\w\+\.java//g')
  pomFile='0'
  while [[ $path != "$CODING_DIR" ]];
  do
    if [[ -n $(find "$path" -maxdepth 1 -mindepth 1 -name 'pom.xml' | head -n 1) ]]; then
      pomFile='1'
      break
    fi
    path="$(dirname "$path")"
    # Sanity check
    if [[ $path == / ]];then break; fi
  done

  if [ "$pomFile" -eq '1' ]; then
    (cd $path; echo $path; mvn package)
    (eval_header_fs "$1";)
  else
    echo "Could not find pom.xml!"
  fi
fi
