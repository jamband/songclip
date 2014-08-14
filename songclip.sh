#!/usr/bin/env bash
set -eu

# Initialization
COMMAND_NAME=$(basename "$0")
CURRENT_STREAM_TITLE=$(osascript -e 'tell application "iTunes" to current stream title')

# Usage
function usage {
  cat <<EOD
Usage: $COMMAND_NAME <subcommand>
  now       Displays current stream title
  list      Displays the contents
  delete    Deletes the title (only one line)
  purge     Deletes the contents (delete all line)
  help      Displays the usage
EOD
}

# Checks the stream
function check_stream {
  if [ "$CURRENT_STREAM_TITLE" = "missing value" ]; then
    echo "Can't retrieve the cunrent stream title." >&2
    return 1
  fi
}

# If the argument is not specified
if [ "$#" -eq 0 ]; then
  check_stream
  if grep -Fqs "$CURRENT_STREAM_TITLE" "$CLIP_FILE"; then
    echo "Current stream title is already exists." >&2
    exit 1
  fi
  echo "$CURRENT_STREAM_TITLE" >>"$CLIP_FILE"
  echo "Clipped: $CURRENT_STREAM_TITLE"
  exit 0
fi

# Divides the processing by the sub-command
case "$1" in
  now)
    check_stream
    echo "Now playing: $CURRENT_STREAM_TITLE"
    ;;
  list)
    cat -n "$CLIP_FILE"
    ;;
  delete)
    read -p "Please enter the line number: " input
    expr "$input" + 1 >/dev/null 2>&1 | true
    if [ "${PIPESTATUS[0]}" -lt 2 ]; then
      if [ "$input" -ne 0 -a "$input" -le $(awk 'END { print NR }' "$CLIP_FILE") ]; then
        sed -i "" "${input}d" "$CLIP_FILE"
        echo "Deleted a line."
        exit 0
      fi
    fi
    echo "There is no such line. Please try again." >&2
    exit 1
    ;;
  purge)
    read -p "Are you sure you want to empty the file? (yes|no): " input
    if [ $input = "y" -o "$input" = "yes" ]; then
      cat /dev/null >"$CLIP_FILE"
      echo "Purged the contents."
    fi
    ;;
  *)
    usage
    exit 1
    ;;
esac

exit 0
