#compdef krates
#autoload

_krates() {
  local -a compreply
  compreply=($(krates complete ${words[*]}))
  _describe -t krates 'krates' compreply
  return 0
}

_krates
