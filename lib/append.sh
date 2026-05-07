#!/usr/bin/env bash
# Idempotent marked-block writes for shell config files.
#
# Markers look like:
#   # >>> bootstrap:mise >>>
#   eval "$(mise activate zsh)"
#   # <<< bootstrap:mise <<<
#
# append_marked is safe to call on every run — it removes the previous
# block before re-inserting, so content never accumulates.

# remove_marked <file> <marker>
# Strips the named block from the file. No-op if the file or block doesn't exist.
remove_marked() {
  local file="$1" marker="$2"
  [[ -f "$file" ]] || return 0

  local begin="# >>> bootstrap:${marker} >>>"
  local end="# <<< bootstrap:${marker} <<<"

  if ! grep -qF "$begin" "$file"; then
    return 0
  fi

  local tmp
  tmp=$(mktemp)
  # Remove lines from begin marker to end marker (inclusive).
  awk -v b="$begin" -v e="$end" '
    $0 == b { skip=1; next }
    $0 == e { skip=0; next }
    !skip   { print }
  ' "$file" > "$tmp"
  run mv "$tmp" "$file"
}

# append_marked <file> <marker> <content>
# Idempotently appends a marked block to <file>.
# Backs up the file on first write.
append_marked() {
  local file="$1" marker="$2" content="$3"

  # Create the file if it doesn't exist.
  if [[ ! -f "$file" ]]; then
    run touch "$file"
  fi

  # Remove any previous block with this marker before re-adding.
  remove_marked "$file" "$marker"

  backup_file "$file"

  local begin="# >>> bootstrap:${marker} >>>"
  local end="# <<< bootstrap:${marker} <<<"

  if is_dryrun; then
    printf "${_YLW}  [dry-run]${_RST} append block '%s' to %s\n" "$marker" "$file" >&2
    return 0
  fi

  {
    printf '\n%s\n' "$begin"
    printf '%s\n' "$content"
    printf '%s\n' "$end"
  } >> "$file"

  info "wrote block '${marker}' to ${file}"
}
