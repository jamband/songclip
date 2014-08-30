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
  exit 1
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

# Divides the processing by sub-command
case "$1" in
  now)
    title=$(current_stream_title)
    echo "Now playing: $title"
    ;;
  list)
    cat -n "$CLIPFILE"
    ;;
  delete)
    [ "$#" -eq 2 ] || usage
    expr "$2" + 1 >/dev/null 2>&1 | true
    if [ "${PIPESTATUS[0]}" -lt 2 ]; then
      if [ "$2" -ne 0 -a "$2" -le $(awk 'END {print NR}' "$CLIPFILE") ]; then
        sed -i "" "${2}d" "$CLIPFILE"
        echo "Deleted a line."
        exit 0
      fi
    fi
    echo "There is no such line. Please try again." >&2
    exit 1
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
    ;;
esac

exit 0
