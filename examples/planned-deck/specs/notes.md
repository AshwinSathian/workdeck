# Notes

A specification for a small shell library that keeps short notes in one text file. It is written for people, not for the planner.

## Overview

A person keeps short notes while working: a thing to check, a number to remember. They are few, they are short, and losing one is a nuisance and no more. So the notes live in a plain text file that any editor can open, and the library is small enough to read in a minute.

## Storage

- The functions are in one file, `src/notes.sh`, which another script sources.
- Every function reads and writes the file named by `NOTES_FILE`, which is `notes.txt` in the current directory when the variable is not set.
- A note is one line of the file: a number, a tab, and the text.
- `note_add <text>` appends a note. Its number is one more than the highest number in the file, or 1 when the file is empty or missing.
- A text that is empty, or that holds a tab or a newline, is refused with exit 1 and nothing is written.

## Removal

- `note_remove <number>` deletes the line with that number and leaves every other line as it was.
- A number that no note has is refused with exit 1, and the file is not changed.

## Listing

- `note_list` prints every note as `<number>  <text>`, in the order of the file.
- `note_list <word>` prints only the notes whose text holds that word, whatever its case.
- With no note to print it prints nothing and exits 0.

## Export

- `note_export` prints the notes as a markdown list, one `- <text>` line for each, in the order of the file.
- It takes the same word as `note_list` and prints the same notes.

## Non-goals

- Editing a note. Remove it and add another.
- More than one file, tags, dates, or a sync between machines.
- A command-line program. The functions are sourced.
