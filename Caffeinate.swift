import AppKit
import SwiftUI

@MainActor
final class CaffeinateController: ObservableObject {
    @Published var keepAwake = false {
        didSet { updateProcess() }
    }
    @Published var keepDisplayAwake = false {
        didSet { updateProcess() }
    }
    @Published private(set) var errorMessage: String?

    private var process: Process?

    private func updateProcess() {
        stop()
        errorMessage = nil
        guard keepAwake else { return }

        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        // Waiting on our PID releases the assertions even if this app crashes.
        task.arguments = [keepDisplayAwake ? "-di" : "-i", "-w", String(ProcessInfo.processInfo.processIdentifier)]

        do {
            try task.run()
            process = task
        } catch {
            keepAwake = false
            errorMessage = "Could not start caffeinate: \(error.localizedDescription)"
        }
    }

    func stop() {
        if let process, process.isRunning {
            process.terminate()
            process.waitUntilExit()
        }
        process = nil
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let controller = CaffeinateController()

    func applicationWillTerminate(_ notification: Notification) {
        controller.stop()
    }
}

@main
struct CaffeinateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        MenuBarExtra {
            CaffeinateMenu(controller: delegate.controller)
        } label: {
            MenuBarIcon(controller: delegate.controller)
        }
        .menuBarExtraStyle(.menu)
    }
}

private struct MenuBarIcon: View {
    @ObservedObject var controller: CaffeinateController

    var body: some View {
        Image(systemName: controller.keepAwake ? "cup.and.saucer.fill" : "cup.and.saucer")
            .accessibilityLabel(controller.keepAwake ? "Caffeinate: awake" : "Caffeinate: off")
    }
}

private struct CaffeinateMenu: View {
    @ObservedObject var controller: CaffeinateController

    var body: some View {
        Text(controller.keepAwake ? "Keeping Mac awake" : "Caffeinate is off")
        Divider()
        Toggle("Keep Mac awake", isOn: $controller.keepAwake)
        Toggle("Keep display awake", isOn: $controller.keepDisplayAwake)
            .disabled(!controller.keepAwake)
        if let errorMessage = controller.errorMessage {
            Text(errorMessage)
        }
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}
