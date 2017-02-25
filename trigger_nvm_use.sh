#!/bin/bash

triggerNvmUse() {
    config="$HOME/.currentNvm"
    nvmrc="${PWD}/.nvmrc"
    if ! [[ -e "$nvmrc" ]]; then return 1; fi
    if [[ -e $config && $(nvm which) == *$(cat "$config")* ]]; then return 1; fi
    nvm use
    echo -n "$(nvm current)" > "$config"
    return 0
}

if [[ ! $PROMPT_COMMAND == *triggerNvmUse\;* ]]
then
    prefix=""
    if [[ -n $PROMPT_COMMAND && ! $PROMPT_COMMAND == *\; ]]
    then
        prefix=";"
    fi
    PROMPT_COMMAND=$PROMPT_COMMAND$prefix"triggerNvmUse;"
fi