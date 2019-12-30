_krates_complete() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"
  local completions="$(krates complete ${COMP_WORDS[*]})"
  COMPREPLY=( $(compgen -W "$completions" -- "$word") )
}

which krates > /dev/null && complete -F _krates_complete krates
