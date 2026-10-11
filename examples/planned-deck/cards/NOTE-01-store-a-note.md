---
id: NOTE-01
title: Store a note
size: XS
depends:
done: true
---

## Read
- specs/notes.md (row NOTE-01: Storage)

## Touch
- src/notes.sh (new)
- tests/notes.sh (new)
- test.sh (new)

## Tests
- note add numbers from one
- note add refuses an empty text a tab and a newline

## Acceptance
- `src/notes.sh` is sourced, and uses the file named by `NOTES_FILE`, `notes.txt` when that is not set
- `note_add <text>` appends a line with a number, a tab and the text
- The number is one more than the highest in the file, and 1 for an empty or missing file
- An empty text, and a text with a tab or a newline, is refused with exit 1 and nothing is written
- `sh test.sh` runs every file in `tests/` and fails when one fails

## Out of scope
- Printing the notes (NOTE-03)

## Notes
- The specification names no test runner. `test.sh` is the check command in `workdeck.conf`, so this card, the first, creates it.
