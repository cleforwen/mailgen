# MailGen

A macOS menu bar app that generates unique random email addresses.

## Requirements

- macOS 13 or later
- Xcode Command Line Tools (includes Swift)

Install the CLI tools if you haven't already:

```bash
xcode-select --install
```

## Build

```bash
swift build -c release
```

The compiled binary will be at `.build/release/MailGen`.

## Run

```bash
.build/release/MailGen &
```

The app runs as a background accessory process — no Dock icon. Look for the **envelope icon** in your menu bar.

## Usage

| Action | Keyboard shortcut |
|--------|-------------------|
| Generate new email | `G` |
| Copy current email | `C` |
| Quit | `Q` |

Each generated email is guaranteed to be unique within a session (across 6,912 possible combinations). Once all combinations are exhausted the pool resets.
