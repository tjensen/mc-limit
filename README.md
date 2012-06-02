MC-Limit
========

Minecraft Limiter (mc-limit) launches Minecraft in offline mode
and automatically terminates the game after it has been played for
a pre-determined amount of time.

## Requirements

* Minecraft (http://minecraft.net/download)
* Java VM (http://java.com/download)
* Ruby 1.9.x (http://ruby-lang.org/en/downloads)

## How to install it

Run `gem install mc-limit`.

## How to configure it

The utility uses environment variables for its configuration.

### Default time limit

Set the `DEFAULT_MC_LIMIT` variable to equal the default number of
minutes of Minecraft play to allow per day.  If the variable is not
set, the default time limit will be 30 minutes.

### Remaining time file

Set the `MC_LIMIT_FILE` variable to the full pathname of the file
that is used to store the remaining play time between runs.  If the
variable is not set, the default file is:

- Windows: `%APPDATA%\.mc-limit\remaining.yml`
- Others: `$HOME/.mc-limit/remaining.yml`

### Admin password

Set the `MC_LIMIT_ADMIN_PASSWORD` variable to be the plain text
password required in order to run the administration tool.  If this
variable is not set, the administration tool will not run.

### Game command

Set the `MC_LIMIT_COMMAND` variable to the complete command line
used to launch Minecraft.

## How to run it

Run "mc-limit" to launch Minecraft.  I recommend creating a desktop
shortcut to make it easier to run.

### Administration tool

Run "mc-limit-admin" to launch the administration tool.  This tool
can be used to add or subtract minutes from today's limit.

## Security

This utility is by no means hacker-proof.  Any curious child (or
adult) who is literate and moderately skilled with computers is
capable of discovering how to defeat the time limit.  I consider it
a challenge for my kids.

## To-Do List

* Make it portable
* Display a timer while Minecraft is running that shows how much play
  time is left.
* Improve security.

