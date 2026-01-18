import AppKit

// MARK: - Argument Parsing

struct Arguments {
    let command: String
    let message: String

    static func parse() -> Arguments? {
        let args = CommandLine.arguments
        var command: String?
        var message = "Claude Code needs your attention"

        var i = 1
        while i < args.count {
            switch args[i] {
            case "--command":
                if i + 1 < args.count {
                    command = args[i + 1]
                    i += 2
                } else {
                    printUsage()
                    return nil
                }
            case "--message":
                if i + 1 < args.count {
                    message = args[i + 1]
                    i += 2
                } else {
                    printUsage()
                    return nil
                }
            case "--help", "-h":
                printUsage()
                return nil
            default:
                print("Unknown argument: \(args[i])")
                printUsage()
                return nil
            }
        }

        guard let command = command else {
            print("Error: --command is required")
            printUsage()
            return nil
        }

        return Arguments(command: command, message: message)
    }

    static func printUsage() {
        print("""
        Usage: focus-overlay --command "<shell command>" [--message "Custom message"]

        Options:
          --command <cmd>    Required. Shell command to run when overlay is clicked.
          --message <msg>    Optional. Message to display on the overlay.
                             Default: "Claude Code needs your attention"
          --help, -h         Show this help message.

        Example:
          focus-overlay --command "wezterm cli activate-pane --pane-id 123"
        """)
    }
}

// MARK: - Application Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: OverlayWindow?
    let arguments: Arguments

    init(arguments: Arguments) {
        self.arguments = arguments
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Activate app to take keyboard focus
        NSApp.activate(ignoringOtherApps: true)

        let command = arguments.command

        window = OverlayWindow(
            message: arguments.message,
            onDismiss: { [weak self] in
                // Run the provided command via shell
                let process = Process()
                process.executableURL = URL(fileURLWithPath: "/bin/sh")
                process.arguments = ["-c", command]

                do {
                    try process.run()
                    process.waitUntilExit()
                } catch {
                    print("Failed to run command: \(error)")
                }

                self?.window?.close()
                NSApp.terminate(nil)
            },
            onCancel: { [weak self] in
                // Just close without running command
                self?.window?.close()
                NSApp.terminate(nil)
            }
        )
    }
}

// MARK: - Main

guard let arguments = Arguments.parse() else {
    exit(1)
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)

let delegate = AppDelegate(arguments: arguments)
app.delegate = delegate

app.run()
