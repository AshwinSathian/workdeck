---
id: NOTE-03b
title: Filter the list by a word
size: XS
depends: NOTE-03
done: false
---

## Read
- specs/notes.md (the heading Listing: this card is the remainder of NOTE-03)
- src/notes.sh
- tests/notes.sh

## Touch
- src/notes.sh
- tests/notes.sh

## Tests
- note list with a word prints only the notes that hold it

## Acceptance
- `note_list <word>` prints only the notes whose text holds that word, whatever its case
- `note_list` with no word prints what it printed before: the NOTE-03 test passes

## Out of scope
- The markdown form of the same notes (NOTE-04)

## Notes
- Created by handoff when NOTE-03 was split, with `card new NOTE-03b ... --depends NOTE-03`. It is a card written in a session, not from a row, so its first `Read` item has no `(row ...)` comment.
