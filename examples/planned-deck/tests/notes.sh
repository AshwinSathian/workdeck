#!/bin/sh
. src/notes.sh
NOTES_FILE=$(mktemp)
trap 'rm -f "$NOTES_FILE"' EXIT

test_note_add_numbers_from_one() {
  rm -f "$NOTES_FILE"
  note_add 'check the fuse' && note_add 'call back at 4'
  [ "$(cut -f1 "$NOTES_FILE" | tr '\n' ' ')" = '1 2 ' ] || { echo "FAIL: note add numbers from one"; exit 1; }
}

test_note_add_refuses_an_empty_text_a_tab_and_a_newline() {
  : > "$NOTES_FILE"
  if note_add '' || note_add 'a	b' || note_add 'a
b'; then echo "FAIL: note add refuses an empty text a tab and a newline"; exit 1; fi
  [ ! -s "$NOTES_FILE" ] || { echo "FAIL: a refused note was written"; exit 1; }
}

test_note_list_prints_every_note_in_order() {
  : > "$NOTES_FILE"
  note_add 'check the fuse' && note_add 'call back at 4'
  [ "$(note_list)" = '1  check the fuse
2  call back at 4' ] || { echo "FAIL: note list prints every note in order"; exit 1; }
}

test_note_add_numbers_from_one
test_note_add_refuses_an_empty_text_a_tab_and_a_newline
test_note_list_prints_every_note_in_order
