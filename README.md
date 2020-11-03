# mpv-sub-pause

An mpv script that automatically pauses after each subtitle line.
Mostly intended for language learning.

The default key binding for toggling auto-pause is `n`.  
To use a custom key add a line like the following to your `input.conf`:

```
X script-binding sub-pause-toggle
```

## Known Issues

If there are multiple subtitles visible at the same time (e.g. one at
the top and one at the bottom, or on-screen text with SubStation Alpha
(ASS)) the script will only pause at the end of the last visible line.

To my knowledge, there is no simple fix for this due to the way mpv
presents subtitle timing information to user scripts.

A more involved solution would be to parse the sub file externally,
but that would probably not be worth the effort considering how rarely
the issue is likely to occur.

---

If you come across any other problems while using the script feel free
to open a GitHub issue or send a pull request.
