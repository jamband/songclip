# songclip
Saves the current stream title of iTunes internet radio to a text file with Bash and AppleScript.

## Requirements
* Mac OSX

## Usage
Sets a CLIP_FILE variable. the title will be save in this file. e.g. .bash_profile, etc...

```sh
export CLIP_FILE=$HOME/path/to/songclip.txt
```

## Commands
* **now** Displays a current stream title
* **list** Displays the clipped song list
* **delete** Deletes the song info (only one line)
* **purge** Purges the contents of existing file (delete all line)
* **help** Displays the Usage

## Demo
![gif](http://jamband.github.io/images/songclip.gif)
