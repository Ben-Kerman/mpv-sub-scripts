# sub-pause

An mpv script that automatically pauses before and/or after each subtitle line.
Mostly intended for language learning.

## Key Bindings

- `(none)`: toggle auto-pause at start of line (`toggle-start`)
- `n`: toggle auto-pause at end of line (`toggle-end`)
- `Alt+r`: skip next pause (`skip-next`)
- `Ctrl+r`: replay active/last line, always available (`replay`)

To use a key binding other than the defaults above add a line like the
following to your `input.conf` (where `X` is the binding and `<action_id>`
is the value in parentheses in the list above):
```
X script-binding sub_pause/<action_id>
```

`sub-pause-toggle-start` doesn't have a default binding and must be assigned
manually.

If you want a binding for both replaying and skipping add a line like this:
```
Ctrl+Alt+SPACE script-binding sub-pause-replay; script-binding sub-pause-skip-next
```

---

`sub_pause/` can be left out, however events triggered from bindings defined
without it will be sent to all scripts, which can lead to conflicts if two
scripts use the same action ID.

When using scoped actions, the script ID before `/` is derived from script's
filename, with the extension removed and all characters except alphanumeric
ASCII characters (A-Z, a-z, 0-9) replaced by `_`.

## Configuration

Create a file at `script-opts/sub_pause.conf` in your mpv config directory:
```
# To set a value remove the leading # and modify it after the =.
# All values given here are defaults. Seconds can be decimal values.

# if set to 'yes', enable pausing at the start of each line by default
#default_start=no

# if set to 'yes', enable pausing at the end of each line by default
#default_end=no

# pause roughly this many seconds before the end of each line
# very low values can result in the line no longer being active after pausing
#end_delta=0.1

# if autopausing is enabled, hide subtitles while not paused
#hide_while_playing=no

# automatically resume playback this many seconds after autopausing
# no effect if less than or equal to zero
#unpause_time=0

# if unpause_time is set, prevent the next automatic unpause by pressing this key
# can be anything that would be an acceptable key binding in mpv's input.conf
#unpause_override=SPACE

# if set to 'yes' (the default), the previous line will be replayed after
# invoking `replay` if there is currently no active line
#replay_prev=yes
```

## Known Issues

If there are multiple subtitles visible at the same time (e.g. one at the top
and one at the bottom, or on-screen text with SubStation Alpha(ASS) subs) the
script will only pause at the end of the last visible line. While it would be
possible to fix this at least some of the time by saving every change in the
subtitle end time this(in my opinion) doesn't justify the additional
complexity considering how rare such situations are.

---

If you come across any other problems while using the script feel free to open
a GitHub issue or send a pull request.


# sub-skip

This script allows automatically skipping parts of a video that don't contain
any subtitles. Skipping can be done either by speeding up playback while no
subtitles are present or by seeking to the start of the next subtitle line,
skipping the interval between lines entirely.

## How To Use

The script works by briefly changing subtitle delay so that the next line
starts at the current video/audio time, recording the difference between the
original and shifted subtitle delay and then speeding up or seeking to the
start of the next line (calculated from the difference).

This works best if mpv is forced to always demultiplex enough of the video for
the next subtitle line to be almost always available by setting
`demuxer-readahead-secs` to a value between 60-120 in `mpv.conf`.
Alternatively, enabling cache for all videos with `cache=yes` also works.

If demuxer readahead or cache are not set explicitly it is possible for the
next subtitle line to be unavailable even if it starts within the next few
seconds. The script can deal with this but works best if one of the config
entries from above is set.

## Key Bindings
- `Ctrl+n`: activate skipping (`toggle`)
- `Ctrl+Alt+n`: toggle between speedup and seek skip (`switch-mode`)
- `Ctrl+Alt+[`: decrease skip speed by 0.1 (`decrease-speed`)
- `Ctrl+Alt+]`: increase skip speed by 0.1 (`increase-speed`)
- `Ctrl+Alt+-`: decrease skip interval by 0.25s (`decrease-interval`)
- `Ctrl+Alt++`: increase skip interval by 0.25s (`increase-interval`)

When changing the interval using the numpad +/- keys, it might be necessary to
also press shift, even if it's not part of the binding.

As explained for `sub-pause`, additional bindings can be assigned in `input.conf`:
```
X script-binding sub_skip/<action_id>
```

## Configuration

Create a file at `script-opts/sub_skip.conf` in your mpv config directory:
```
# To set a value remove the leading # and modify it after the =.
# All values given here are defaults. Seconds can be decimal values.

# if set to 'yes', enable skipping by default
#default_state=no

# if set to 'yes', use seek mode by default
#seek_mode_default=no

# any interval between subtitle lines longer than this value in seconds will be skipped
#min_skip_interval=3

# what speed to use while skipping if not in seek mode
#speed_skip_speed=2.5

# how many seconds after the end of a line to wait for before starting to skip
#lead_in=0

# how many seconds before the start of the next line to stop skipping at
#lead_out=1

# how much to change skip speed by when invoking sub-skip-{de,in}crease-speed
#speed_skip_speed_delta=0.1

# how many seconds to change the minimum interval by when invoking sub-skip-{de,in}crease-interval
#min_skip_interval_delta=0.25
```

---

`sub-skip` is inspired by and partially based on `speed-transition` from
https://github.com/zenyd/mpv-scripts, but rewritten from scratch.
