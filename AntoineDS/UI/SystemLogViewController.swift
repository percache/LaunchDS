//
//  SystemLogViewController.swift
//  AntoineDS
//
//  System log file viewer.
//  Black/white/orange theme — no green text.
//

import UIKit

class SystemLogViewController: UIViewController {

    // MARK: - Theme
    private let accentOrange = UIColor(red: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)
    private let darkCardBg = UIColor(red: 0.11, green: 0.11, blue: 0.118, alpha: 1.0) // #1C1C1E

    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.118, alpha: 1.0)
        tv.textColor = .white
        tv.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        tv.indicatorStyle = .white
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private var timer: Timer?
    private var lastSize: UInt64 = 0
    private var logPath = "/var/log/com.apple.xpc.launchd/launchd.log"
    private var allPaths: [String] = []
    private var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "System Logs"
        view.backgroundColor = .black

        // Orange navigation tint
        navigationController?.navigationBar.tintColor = accentOrange
        navigationController?.toolbar.tintColor = accentOrange

        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        // Find all readable log files
        allPaths = findLogFiles()
        if let idx = allPaths.firstIndex(of: logPath) { currentIndex = idx }

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "doc.text"),
            style: .plain, target: self, action: #selector(pickLogFile))

        setToolbarItems([
            UIBarButtonItem(image: UIImage(systemName: "arrow.down.to.line"),
                          style: .plain, target: self, action: #selector(scrollToBottom)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"),
                          style: .plain, target: self, action: #selector(reload)),
        ], animated: false)
        navigationController?.setToolbarHidden(false, animated: false)

        loadLog()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tailLog()
        }
    }

    deinit { timer?.invalidate() }

    // MARK: - Log file discovery
    private func findLogFiles() -> [String] {
        var files: [String] = []
        let dirs = ["/var/log", "/var/log/com.apple.xpc.launchd",
                    "/var/log/asl", "/var/log/DiagnosticMessages",
                    "/private/var/log"]
        for dir in dirs {
            if let contents = try? FileManager.default.contentsOfDirectory(atPath: dir) {
                for f in contents {
                    let path = (dir as NSString).appendingPathComponent(f)
                    var isDir: ObjCBool = false
                    FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
                    if !isDir.boolValue { files.append(path) }
                }
            }
        }
        // Also add known paths
        let known = ["/var/log/com.apple.xpc.launchd/launchd.log",
                     "/var/log/syslog", "/var/log/system.log"]
        for k in known where !files.contains(k) {
            if FileManager.default.fileExists(atPath: k) { files.append(k) }
        }
        return files.sorted()
    }

    // MARK: - Actions
    @objc private func pickLogFile() {
        let alert = UIAlertController(title: "Log Files", message: "\(allPaths.count) files found", preferredStyle: .actionSheet)
        for (i, path) in allPaths.enumerated() {
            let name = (path as NSString).lastPathComponent
            let dir = ((path as NSString).deletingLastPathComponent as NSString).lastPathComponent
            alert.addAction(UIAlertAction(title: "\(dir)/\(name)", style: .default) { [weak self] _ in
                self?.currentIndex = i
                self?.logPath = path
                self?.lastSize = 0
                self?.loadLog()
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func reload() {
        lastSize = 0
        loadLog()
    }

    @objc private func scrollToBottom() {
        let range = NSRange(location: max(0, textView.text.count - 1), length: 1)
        textView.scrollRangeToVisible(range)
    }

    // MARK: - Log loading
    private func loadLog() {
        title = (logPath as NSString).lastPathComponent
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: logPath)) else {
            textView.text = "Cannot read: \(logPath)\n\nAvailable files:\n" + allPaths.joined(separator: "\n")
            return
        }
        // Show last 100KB
        let maxShow: Int = 100_000
        let showData = data.count > maxShow ? data.suffix(maxShow) : data
        textView.text = String(data: showData, encoding: .utf8) ?? "(binary data, \(data.count) bytes)"
        lastSize = UInt64(data.count)
        scrollToBottom()
    }

    private func tailLog() {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: logPath),
              let size = attrs[.size] as? UInt64, size > lastSize else { return }
        guard let fh = FileHandle(forReadingAtPath: logPath) else { return }
        fh.seek(toFileOffset: lastSize)
        let newData = fh.readDataToEndOfFile()
        fh.closeFile()
        if let text = String(data: newData, encoding: .utf8), !text.isEmpty {
            textView.text += text
            lastSize = size
            scrollToBottom()
        }
    }
}
