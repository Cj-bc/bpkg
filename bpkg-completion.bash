#!/bin/bash

CMDS="json install package term suggest init utils update list show getdeps"
flags="-h -V"

function _bpkg-completion
{
  local cur prev cword  
  _get_comp_words_by_ref -n : cur prev cword

  packages=($(bpkg list))

  # if there's no words before, return all subcommands
  if [ ${#COMP_WORDS[@]} -le 2 ]
  then
    COMPREPLY=($(compgen -W "$flags $CMDS" -- "$cur"))
  else

    case "$prev" in
      "install" ) COMPREPLY=($(compgen -W "${packages[*]}" -- "$cur"));;
      "package" )
        # return all parameters in package.json
        if [ -f ./package.json ]
        then
          temp=$(mktemp "/tmp/bpkg-comp.tmp.XXXXX")
          echo $(cat ./package.json | bpkg json -b) > $temp
          vim -e -s "$temp" <<-EOT
          %s/ /\r/g
          g/^[^\[]/d
          %s/,.*$//g
          %s/[\[\]"]//g
          %s/r/,/g
          %s/[\n\r]/ /g
          %s/,/r/g
          w!
EOT
          rep=$(cat $temp)
          rm "$temp"
          COMPREPLY=($(compgen -W "$rep" -- "$cur"))
        fi
        ;;
    esac
  fi


}

complete -F _bpkg-completion bpkg
