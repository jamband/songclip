# songclip
Saves the current stream title of iTunes internet radio to a text file with Bash and AppleScript.

## Demo
![gif](http://jamband.github.io/images/songclip.gif)

## Requirements
* Mac OSX

## Install
Download the songclip.sh and put in directory any.

## Usage
Sets a CLIPFILE variable. the title will be save in this file. e.g. .bash_profile, etc...

```sh
export CLIPFILE=$HOME/path/to/songclip.txt
```

## Commands
* **now** Displays the current stream title
* **list** Displays the title list
* **delete [id]** Deletes a title (only one line)
* **purge** Purges the contents (delete all lines)
* **help** Displays the usage
