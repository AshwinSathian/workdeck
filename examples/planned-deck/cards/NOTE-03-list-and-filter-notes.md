---
id: NOTE-03
title: List and filter notes
size: S
depends: NOTE-01
done: true
---

## Read
- specs/notes.md (row NOTE-03: Listing)
- src/notes.sh
- tests/notes.sh

## Touch
- src/notes.sh
- tests/notes.sh

## Tests
- note list prints every note in order

## Acceptance
- `note_list` prints every note as `<number>  <text>`, in the order of the file
- With no note to print it prints nothing and exits 0

## Out of scope
- The markdown form of the same notes (NOTE-04)
- The filter by a word. Split at handoff: NOTE-03b owns it.

## Notes
- Split at handoff. The row has three `does` lines and this card keeps two of them. The third, `note_list <word>`, moved to NOTE-03b with its test.
