#!/usr/bin/env bash
set -eu

# Gets the command name
declare -r COMMAND_NAME=$(basename "$0")

# Gets the title from iTunes
declare -r CURRENT_STREAM_TITLE=$(osascript -e '
  if application "iTunes" is running
    tell application "iTunes" to current stream title
  end if
')

# Usage
usage() {
  cat << EOD
Usage: $COMMAND_NAME <subcommand>
  now       Displays a current stream title
  list      Displays the clipped song list
  delete    Deletes the song info (only one line)
  purge     Purges the contents of existing file (delete all line)
  help      Displays the Usage
EOD
}

# Checks the stream
check_stream() {
  if [ "$CURRENT_STREAM_TITLE" = "missing value" -o "$CURRENT_STREAM_TITLE" = "" ]; then
    echo "Error: Can't retrieve the cunrent stream title." 1>&2
    return 1
  fi
}

# If the argument is not specified
if [ "$#" -eq 0 ]; then
  check_stream
  if grep -Fqs "$CURRENT_STREAM_TITLE" "$CLIP_FILE"; then
    echo "Now Playing the stream title is already exists." 1>&2
    exit 1
  fi
  echo "$CURRENT_STREAM_TITLE" >> "$CLIP_FILE"
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
    read -p "Please enter the line number: " answer
    expr "$answer" + 1 >/dev/null 2>&1 | true

    if [ "${PIPESTATUS[0]}" -lt 2 ]; then
      rows=$(awk 'END { print NR }' "$CLIP_FILE")

      if [ "$answer" -ne 0 -a "$answer" -le "$rows" ]; then
        sed -i "" -e "${answer}d" "$CLIP_FILE"
        echo "Deleted a line."
        exit 0
      fi
    fi
    echo "There is no such line. Please try again." 1>&2
    exit 1
    ;;
  purge)
    read -p "Are you sure you want to empty the file? (yes|no): " answer
    if [ $answer = "y" -o "$answer" = "yes" ]; then
      echo -n > "$CLIP_FILE"
      echo "Purged the contents of the file."
    fi
    ;;
  *)
    usage 1>&2
    exit 1
    ;;
esac

exit 0
