# focus-overlay

A minimal macOS utility that displays a floating text box and runs a command when dismissed.

## Usage

```bash
focus-overlay --command "<shell command>" [--message "Custom message"]
```

### Options

- `--command <cmd>` - Required. Shell command to run when overlay is dismissed.
- `--message <msg>` - Optional. Message to display. Default: "Claude Code needs your attention"

### Controls

- **Click anywhere** - Run command and close
- **Space** - Run command and close
- **ESC** - Close without running command

## Example

```bash
focus-overlay --command "wezterm cli activate-pane --pane-id 123 && open -a WezTerm" --message "Click to focus terminal"
```

## Building

```bash
swift build -c release
```

Binary will be at `.build/release/focus-overlay`.

## Claude Code Integration

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/notify-and-focus.sh"
          }
        ]
      }
    ]
  }
}
```

Create `~/.claude/scripts/notify-and-focus.sh`:

```bash
#!/bin/bash
PANE_ID="$WEZTERM_PANE"
FOCUS_OVERLAY="/path/to/focus-overlay"
FOCUS_CMD="/Applications/WezTerm.app/Contents/MacOS/wezterm cli activate-pane --pane-id $PANE_ID && open -a WezTerm"
"$FOCUS_OVERLAY" --command "$FOCUS_CMD" --message "Claude Code needs your attention"
```
