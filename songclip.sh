#!/usr/bin/env bash
set -eu

# Usage
function usage {
  cat <<EOD
Usage: $(basename "$0") <subcommand> [option]
  now           Displays current stream title
  list          Displays the contents
  delete [id]   Deletes the title (only one line)
  purge         Deletes the contents (delete all line)
  help          Displays the usage
EOD
}

# Gets the current stream title
function current_stream_title {
  title=$(osascript -e '
    if application "iTunes" is running
      tell application "iTunes" to current stream title
    end if
  ')
  if [ "$title" = "" -o "$title" = "missing value" ]; then
    echo "Can't retrieve the cunrent stream title." >&2
    return 1
  fi
  echo "$title"
}

# Checks the argument count
function check_arg_count {
  if [ "$1" -ne "$2" ]; then
    usage
    return 1
  fi
}

# Checks the number
function check_number {
  expr "$1" + 1 >/dev/null 2>&1 | true
  if [ "${PIPESTATUS[0]}" -lt 2 ]; then
    if [ "$1" -ne 0 -a "$1" -le $(awk 'END {print NR}' "$CLIPFILE") ]; then
      return 0
    fi
  fi
  echo "There is no such line. Please try again." >&2
  return 1
}

# If the argument is not specified
if [ "$#" -eq 0 ]; then
  title=$(current_stream_title)
  if grep -Fqs "$title" "$CLIPFILE"; then
    echo "Current stream title is already exists." >&2
    exit 1
  fi
  echo "$title" >>"$CLIPFILE"
  echo "Clipped: $title"
  exit 0
fi

# Divides the processing by the sub-command
case "$1" in
  now)
    echo "Now playing: $(current_stream_title)"
    ;;
  list)
    cat -n "$CLIPFILE"
    ;;
  delete)
    check_arg_count "$#" 2
    check_number "$2"
    sed -i "" "${2}d" "$CLIPFILE"
    echo "Deleted a line."
    ;;
  purge)
    read -p "Are you sure you want to empty the file? (yes|no): " input
    if [ "$input" = "y" -o "$input" = "yes" ]; then
      cat /dev/null >"$CLIPFILE"
      echo "Purged the contents."
    fi
    ;;
  *)
    usage
    exit 1
    ;;
esac

exit 0
