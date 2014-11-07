#!/usr/bin/env bash

function strings_has {
    #/
    local item="$1"

    #/
    local elem

    for elem in "${@:2}";
    do
        [[ "$elem" == "$item" ]] && return 0
    done

    #/
    return 1
}

function strings_uniq {
    #/ $1 is name of result variable to set on return
    local resvar="$1"

    #/ $2 upwards are array items
    shift

    local item_s=("${@}")

    #/
    local item_new_s=()

    for item in "${item_s[@]}"
    do
        strings_has "$item" "${item_new_s[@]}" || item_new_s+=("$item")
    done

    #/
    eval $resvar='( "${item_new_s[@]}" )'
}

function strings_trim()
{
    #/ $1 is name of result variable to set on return
    local resvar="$1"

    #/ $2 upwards are array items
    shift

    local item_s=("${@}")

    #/
    local item_new_s=()

    local item_new

    for item in "${item_s[@]}"
    do
        if [[ "$item" =~ ^[[:space:]]*([^[:space:]].*[^[:space:]])[[:space:]]*$ ]]
        then
            item_new="${BASH_REMATCH[1]}"
        else
            item_new="$item"
        fi
        item_new_s+=("$item_new")
    done

    #/
    eval $resvar='( "${item_new_s[@]}" )'
}

function strings_unempty()
{
    #/ $1 is name of result variable to set on return
    local resvar="$1"

    #/ $2 upwards are array items
    shift

    local item_s=("${@}")

    #/
    local item_new_s=()

    for item in "${item_s[@]}"
    do
        if [ -n "$item" ]; then
            item_new_s+=("$item")
        fi
    done

    #/
    eval $resvar='( "${item_new_s[@]}" )'
}

function strings_lower()
{
    #/ $1 is name of result variable to set on return
    local resvar="$1"

    #/ $2 upwards are array items
    shift

    local item_s=("${@}")

    #/
    local item_new_s=()

    for item in "${item_s[@]}"
    do
        item_new_s+=("${item,,}")
    done

    #/
    eval $resvar='( "${item_new_s[@]}" )'
}

function strings_anyisendof {
    #/
    local item="$1"

    #/
    local elem

    for elem in "${@:2}";
    do
        [[ "$item" == *"$elem" ]] && return 0
    done

    #/
    return 1
}

function find_executable {
    #/ $1 is name of result variable to set on return
    local resvar="$1"

    #/
    local prog="$2"

    #/ 6qhHTHF
    #/ split into a list of extensions
    OIFS="$IFS"
    IFS=';'
    [ -z "$PATHEXT" ] && ext_s=() || ext_s=( $PATHEXT )
    IFS="$OIFS"

    #/ 2pGJrMW
    #/ strip
    strings_trim ext_s "${ext_s[@]}"

    #/ 2gqeHHl
    #/ remove empty
    strings_unempty ext_s "${ext_s[@]}"

    #/ 2zdGM8W
    #/ convert to lowercase
    strings_lower ext_s "${ext_s[@]}"

    #/ 2fT8aRB
    #/ uniquify
    strings_uniq ext_s "${ext_s[@]}"

    #/ 6mPI0lg
    OIFS="$IFS"
    IFS=':'
    ## In Cygwin, |;| in PATH is converted to |:|.
    [ -z "$PATH" ] && dir_path_s=() || dir_path_s=( $PATH )
    IFS="$OIFS"

    #/ 5rT49zI
    #/ insert empty dir path to the beginning
    ##
    ## Empty dir handles the case that |prog| is a path, either relative or
    ##  absolute. See code 7rO7NIN.
    dir_path_s=( '' "${dir_path_s[@]}")

    #/ 2klTv20
    #/ uniquify
    strings_uniq dir_path_s "${dir_path_s[@]}"

    #/ 6bFwhbv
    exe_path_s=()

    for dir_path in "${dir_path_s[@]}"; do
        #/ 7rO7NIN
        #/ synthesize a path with the dir and prog
        if [ "$dir_path" == '' ]; then
            path="$prog"
        else
            path="$dir_path/$prog"
        fi

        #/ 6kZa5cq
        ## assume the path has extension, check if it is an executable
        if strings_anyisendof "$path" "${ext_s[@]}"; then
            if [ -f "$path" ]; then
                exe_path_s=( "${exe_path_s[@]}" "$path" )
            fi
        fi

        #/ 2sJhhEV
        ## assume the path has no extension
        for ext in "${ext_s[@]}"; do
            #/ 6k9X6GP
            #/ synthesize a new path with the path and the executable extension
            path_plus_ext="$path$ext"

            #/ 6kabzQg
            #/ check if it is an executable
            if [ -f "$path_plus_ext" ]; then
                exe_path_s=( "${exe_path_s[@]}" "$path_plus_ext" )
            fi
        done
    done

    #/ 8swW6Av
    #/ uniquify
    strings_uniq exe_path_s "${exe_path_s[@]}"

    #/
    eval $resvar='( "${exe_path_s[@]}" )'
}

function main {
    #/ 9mlJlKg
    if [ "$#" != "1" ]; then
        #/ 7rOUXFo
        #/ print program usage
        echo 'Usage: aoikwinwhich PROG'
        echo ''
        echo '#/ PROG can be either name or path'
        echo 'aoikwinwhich notepad.exe'
        echo 'aoikwinwhich C:\Windows\notepad.exe'
        echo ''
        echo '#/ PROG can be either absolute or relative'
        echo 'aoikwinwhich C:\Windows\notepad.exe'
        echo 'aoikwinwhich Windows\notepad.exe'
        echo ''
        echo '#/ PROG can be either with or without extension'
        echo 'aoikwinwhich notepad.exe'
        echo 'aoikwinwhich notepad'
        echo 'aoikwinwhich C:\Windows\notepad.exe'
        echo 'aoikwinwhich C:\Windows\notepad'

        #/ 3nqHnP7
        return
    fi

    #/ 9m5B08H
    #/ get name or path of a program from cmd arg
    prog="$1"

    #/ 8ulvPXM
    #/ find executables
    find_executable path_s "$prog"

    #/ 5fWrcaF
    #/ has found none, exit
    if [ "${#path_s[@]}" == "0" ]; then
        #/ 3uswpx0
        return
    fi

    #/ 9xPCWuS
    #/ has found some, output
    printf "%s\n" "${path_s[@]}"

    #/ 4s1yY1b
    return
}

main "$@"
