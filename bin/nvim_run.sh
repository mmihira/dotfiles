#!/bin/bash

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


if [ $(echo "$PWD" | grep '/home/mihira/c' -c) -eq '0' ]; then
  echo 'This script only works in the coding directory'
  exit
fi

# Determine what kind of file
type=$(echo "$1" | sed -r 's/(.*)(\.rs|\.py|\.java|\.js|\.sh|\.go)/\2/g')

########################################################################
# Bash run script
########################################################################
if [ "$type" == '.sh' ]; then
  base_file_path=$(echo "$1" | sed 's/\/\w\+\.sh//g')
  exe_name=$(echo "$1" | sed 's/\.sh//g' | sed 's/\/.*\///g')
  (cd $base_file_path; echo $base_file_path; ./"$exe_name.sh")
  exit 0
fi

########################################################################
# Node
########################################################################
if [ "$type" == '.js' ]; then
  base_file_path=$(echo "$1" | sed 's/\/\w\+\.js//g')
  exe_name=$(echo "$1" | sed 's/\.js//g' | sed 's/\/.*\///g')
  ( cd $base_file_path;
    eval_header_fs "$exe_name.js";
  )
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
    ./"$exe_name.py"
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
  while [[ $path != /home/mihira/c ]];
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
  # up until /home/mihira/c
  path=$(echo "$1" | sed 's/\/\w\+\.rs//g')
  cargoFound='0'
  while [[ $path != /home/mihira/c ]];
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
    if [ $(echo "$1" | grep -c "/home/mihira/c/rust_ex") -eq '1' ]; then
      # Special case of in ~/c/rust_ex we want all to compile to ~/c/rust_ex/target
      base_path="/home/mihira/c/rust_ex/target/"
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
if [ "$type" == '.go' ]; then
  # Check if a src directory exists
  # up until $GOPATH
  cacheArg="$1"
  path=$(echo "$cacheArg" | sed 's/\/\w\+\.go//g')
  buildName=$(echo "$path" | sed 's/.*\/\(\w\+\)/\1/g')
  runFound='1'
  if [ "$runFound" -eq '1' ]; then
    (cd $path; echo $path; go install; "$GOPATH/bin/$buildName")
  else
    echo "Could not find run.sh!"
  fi
fi


# Java
########################################################################
if [ "$type" == '.java' ]; then
  # Check if  a run file exists
  # up until /home/mihira/c
  path=$(echo "$1" | sed 's/\/\w\+\.java//g')
  runFound='0'
  while [[ $path != /home/mihira/c ]];
  do
    if [[ -n $(find "$path" -maxdepth 1 -mindepth 1 -name 'run.sh' | head -n 1) ]]; then
      runFound='1'
      break
    fi
    path="$(dirname "$path")"
    # Sanity check
    if [[ $path == / ]];then break; fi
  done

  if [ "$runFound" -eq '1' ]; then
    (cd $path; echo $path; ./run.sh)
  else
    echo "Could not find run.sh!"
  fi
fi
