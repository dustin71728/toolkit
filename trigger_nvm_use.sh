#!/bin/bash

NPM_VERSION_PROMPT_SYMBOL="Ⓝ"
NPM_PROMPT_PREFIX="$NPM_VERSION_PROMPT_SYMBOL REPLACE_VAL "

nvmVersionPrompt_addPrompt() {
    local prompt

    prompt=$(nvmVersionPrompt_getPrompt "$1")

    if [[ ! $PS1 == *$NPM_VERSION_PROMPT_SYMBOL* ]]; then
        PS1="$prompt$PS1"
    elif [[ ! $PS1 == *$prompt* ]]; then
        PS1=$(echo -n "$PS1" | sed -r 's/'"$NPM_VERSION_PROMPT_SYMBOL"' v([[:digit:]]+\.){2}[[:digit:]]+ //')
        PS1="$prompt$PS1"        
    fi
}

nvmVersionPrompt_getPrompt() {
    echo "${NPM_PROMPT_PREFIX/REPLACE_VAL/$1}"
}

nvmVersionPrompt_trigger() {
    local nvmCurrent
    local nvmrc

    nvmCurrent=$(nvm current)
    nvmrc="${PWD}/.nvmrc"

    if ! [[ -e "$nvmrc" ]]; then 
        nvmVersionPrompt_addPrompt "$nvmCurrent"
        return 1
    fi
    if [[ $(nvm which) == *$nvmCurrent* ]]; then 
        nvmVersionPrompt_addPrompt "$nvmCurrent"
        return 1 
    fi

    nvm use

    nvmCurrent=$(nvm current)
    nvmVersionPrompt_addPrompt "$nvmCurrent"
    nvmVersionPrompt_addCommand "nvmVersionPrompt_trigger"
    return 0
}

nvmVersionPrompt_addCommand() {
    if [[ ! $PROMPT_COMMAND == *$1\;* ]]
    then
        prefix=""
        if [[ -n $PROMPT_COMMAND && ! $PROMPT_COMMAND == *\; ]]
        then
            prefix=";"
        fi
        PROMPT_COMMAND=$PROMPT_COMMAND$prefix"$1;"
    fi
}

nvmVersionPrompt_addCommand "nvmVersionPrompt_trigger"