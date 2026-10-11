---
spec: specs/notes.md
spec_blob: 92906be9ecdf0a9bd82e5b5318e9db868ab78c15
prefix: NOTE
level: 2
---

## NOTE-01 Store a note
- size: XS
- spec: Storage
- does: `src/notes.sh` is sourced, and uses the file named by `NOTES_FILE`, `notes.txt` when that is not set
- does: `note_add <text>` appends a line with a number, a tab and the text
- does: The number is one more than the highest in the file, and 1 for an empty or missing file
- does: An empty text, and a text with a tab or a newline, is refused with exit 1 and nothing is written
- not: Printing the notes (NOTE-03)

## NOTE-02 Remove a note
- size: XS
- depends: NOTE-01
- spec: Removal
- does: `note_remove <number>` deletes that line and leaves every other line as it was
- does: A number that no note has is refused with exit 1 and the file is not changed

## NOTE-03 List and filter notes
- size: S
- depends: NOTE-01
- spec: Listing
- does: `note_list` prints every note as `<number>  <text>`, in the order of the file
- does: `note_list <word>` prints only the notes whose text holds that word, whatever its case
- does: With no note to print it prints nothing and exits 0
- not: The markdown form of the same notes (NOTE-04)

## NOTE-04 Export the notes as markdown
- size: XS
- depends: NOTE-03
- spec: Export
- does: `note_export` prints one `- <text>` line for each note, in the order of the file
- does: `note_export <word>` prints the notes that `note_list <word>` prints

## Not planned
- Overview
- Non-goals
