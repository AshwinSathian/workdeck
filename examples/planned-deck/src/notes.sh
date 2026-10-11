# Short notes in one text file: a number, a tab and the text on each line.
NOTES_FILE=${NOTES_FILE:-notes.txt}

note_add() {
  case $1 in '' | *'	'* | *'
'*) return 1 ;; esac
  printf '%s\t%s\n' "$(($(cut -f1 "$NOTES_FILE" 2>/dev/null | sort -n | tail -1) + 1))" "$1" >> "$NOTES_FILE"
}

note_list() { [ ! -f "$NOTES_FILE" ] || sed 's/	/  /' "$NOTES_FILE"; }
