## Index

* [term.cursor_to()](#termcursor_to)
* [term.cursor_moveto()](#termcursor_moveto)
* [term.cursor_up()](#termcursor_up)
* [term.cursor_down()](#termcursor_down)
* [term.cursor_forward()](#termcursor_forward)
* [term.cursor_backward()](#termcursor_backward)
* [term.cursor_line_next()](#termcursor_line_next)
* [term.cursor_line_prev()](#termcursor_line_prev)
* [term.cursor_horizontal()](#termcursor_horizontal)
* [term.cursor_savepos()](#termcursor_savepos)
* [term.cursor_restorepos()](#termcursor_restorepos)
* [term.cursor_save()](#termcursor_save)
* [term.cursor_restore()](#termcursor_restore)
* [term.cursor_hide()](#termcursor_hide)
* [term.cursor_show()](#termcursor_show)
* [term.cursor_getpos()](#termcursor_getpos)
* [term.erase_line_end()](#termerase_line_end)
* [term.erase_line_start()](#termerase_line_start)
* [term.erase_line()](#termerase_line)
* [term.erase_screen_end()](#termerase_screen_end)
* [term.erase_screen_start()](#termerase_screen_start)
* [term.erase_screen()](#termerase_screen)
* [term.erase_saved_lines()](#termerase_saved_lines)
* [term.scroll_down()](#termscroll_down)
* [term.scroll_up()](#termscroll_up)
* [term.tab_set()](#termtab_set)
* [term.tab_clear()](#termtab_clear)
* [term.tab_clearall()](#termtab_clearall)
* [term.beep()](#termbeep)
* [term.hyperlink()](#termhyperlink)
* [term.bold()](#termbold)
* [term.italic()](#termitalic)
* [term.underline()](#termunderline)
* [term.strikethrough()](#termstrikethrough)

### term.cursor_to()

Move the cursor position to a supplied row and column. Both default to `0` if not supplied

#### Arguments

* **$1** (int): row
* **$1** (int): column

### term.cursor_moveto()

Moves cursor position to a supplied _relative_ row and column. Both default to `0` if not supplied (FIXME: implement)

#### Arguments

* **$1** (int): row
* **$1** (int): column

### term.cursor_up()

Moves the cursor up. Defaults to `1` if not supplied

#### Arguments

* **$1** (int): count

### term.cursor_down()

Moves the cursor down. Defaults to `1` if not supplied

#### Arguments

* **$1** (int): count

### term.cursor_forward()

Moves the cursor forward. Defaults to `1` if not supplied

#### Arguments

* **$1** (int): count

### term.cursor_backward()

Moves the cursor backwards. Defaults to `1` if not supplied

#### Arguments

* **$1** (int): count

### term.cursor_line_next()

Moves the cursor to the next line. Defaults to `1` if not supplied

#### Arguments

* **$1** (int): count

### term.cursor_line_prev()

Moves the cursor to the previous line. Defaults to `1` if not supplied

#### Arguments

* **$1** (int): count

### term.cursor_horizontal()

Moves the cursor ?

#### Arguments

* **$1** (int): count

### term.cursor_savepos()

Saves the current cursor position

_Function has no arguments._

### term.cursor_restorepos()

Restores cursor to the last saved position

_Function has no arguments._

### term.cursor_save()

Saves

_Function has no arguments._

### term.cursor_restore()

Restores

_Function has no arguments._

### term.cursor_hide()

Hides the cursor

_Function has no arguments._

### term.cursor_show()

Shows the cursor

_Function has no arguments._

### term.cursor_getpos()

Reports the cursor position to the application as (as though typed at the keyboard)

_Function has no arguments._

### term.erase_line_end()

Erase from the current cursor position to the end of the current line

_Function has no arguments._

### term.erase_line_start()

Erase from the current cursor position to the start of the current line

_Function has no arguments._

### term.erase_line()

Erase the entire current line

_Function has no arguments._

### term.erase_screen_end()

Erase the screen from the current line down to the bottom of the screen

_Function has no arguments._

### term.erase_screen_start()

Erase the screen from the current line up to the top of the screen

_Function has no arguments._

### term.erase_screen()

Erase the screen and move the cursor the top left position

_Function has no arguments._

### term.erase_saved_lines()

_Function has no arguments._

### term.scroll_down()

_Function has no arguments._

### term.scroll_up()

_Function has no arguments._

### term.tab_set()

_Function has no arguments._

### term.tab_clear()

_Function has no arguments._

### term.tab_clearall()

_Function has no arguments._

### term.beep()

Construct a beep

_Function has no arguments._

### term.hyperlink()

Construct hyperlink

#### Arguments

* **$1** (string): text
* **$2** (string): url

### term.bold()

Construct bold

#### Arguments

* **$1** (string): text

### term.italic()

Construct italic

#### Arguments

* **$1** (string): text

### term.underline()

Construct underline

#### Arguments

* **$1** (string): text

### term.strikethrough()

Construct strikethrough

#### Arguments

* **$1** (string): text

