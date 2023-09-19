---
title: Setting up your Integrated Ddevelopment Environment (IDE) for work with Giant Swarm
linkTitle: IDEs
description: In this area we want to help you to set up your IDE for most efficient and painless collaboration with Giant Swarm colleagues and systems.
confidentiality: public
weight: 50
---

You are free to choose the IDE that's best for you. IF you are lucky, others at Giant Swarm are using the same tool, so you can find proven configuration here.

Feel free to share your IDE configuration tipps here.

## Visual Studio Code

### Golang specific

1. Have the official **Go** extension (ID: `golang.go`) published by the **Go Team at Google** installed.
2. Add the following user configuration (On MacOS, go to **Code** > **Settings** > **Settings** or hit **Cmd + ,**. Filter the list by `@ext:golang.go`).
   1. In the **Go: Lint Tool** setting, select `golangci-lint`. When you are informed that you must install the tool, hit the **Install** button and wait for a few moments.
   2. In the **Go: Lint Flags** setting, add these items:
      - `-E=gosec`
      - `-E=goconst`

The Go extension is by default configured to build your current workspace on changes. You can also trigger builds, test runs etc. via the command palette (Cmd + Shift + P). Enter `Go:` into the palette to see which actions are offered.

Problems found in build and linting will show up in the problems list. You can open this view via the command palette (Cmd + Shift + P) and selecting `Problems: Focus on Problems View`.

There is also a dedicated Go main menu item with some potentially useful actions.

### Synopsis

If you prefer editing the raw settings JSON, open the command palette (Cmd + Shift + P) and select/enter `Preferences: Open User Settings (JSON)`. Then add/set the following top level entries:

```json5
    // Sets golangci-lint as the linter
    "go.lintTool": "golangci-lint",

    // Adds command line flags for golangci-lint
    "go.lintFlags": [
        "-E=gosec",
        "-E=goconst"
    ]
```
