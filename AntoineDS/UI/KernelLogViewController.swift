//
//  KernelLogViewController.swift
//  LaunchdDS
//
//  System log file viewer — reads /var/log/ after sandbox escape.
//

import UIKit

class KernelLogViewController: UIViewController {

    private let accentOrange = UIColor(red: 1.0, green: 0.584, blue: 0.0, alpha: 1.0)

    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.118, alpha: 1.0)
        tv.textColor = .white
        tv.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        tv.indicatorStyle = .white
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        return tv
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = .monospacedSystemFont(ofSize: 10, weight: .regular)
        l.textColor = UIColor(white: 0.5, alpha: 1)
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private var refreshTimer: Timer?
    private var lastLogSize: UInt64 = 0
    private var currentLogPath = ""

    private let logPaths = [
        "/var/log/com.apple.xpc.launchd/launchd.log",
        "/var/log/system.log",
        "/var/log/syslog",
        "/private/var/log/com.apple.xpc.launchd/launchd.log",
        "/private/var/log/system.log",
        "/var/log/install.log",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "System Logs"
        view.backgroundColor = .black
        navigationController?.navigationBar.tintColor = accentOrange
        navigationController?.toolbar.tintColor = accentOrange

        view.addSubview(textView)
        view.addSubview(statusLabel)
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusLabel.heightAnchor.constraint(equalToConstant: 20),
            textView.topAnchor.constraint(equalTo: statusLabel.bottomAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        setToolbarItems([
            UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"),
                          style: .plain, target: self, action: #selector(reload)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "arrow.down.to.line"),
                          style: .plain, target: self, action: #selector(scrollToBottom)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"),
                          style: .plain, target: self, action: #selector(shareLog)),
        ], animated: false)
        navigationController?.setToolbarHidden(false, animated: false)

        loadLog()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.tailLog()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    private func findReadableLog() -> String? {
        for path in logPaths {
            if FileManager.default.isReadableFile(atPath: path) { return path }
        }
        for dir in ["/var/log", "/var/log/com.apple.xpc.launchd"] {
            guard let files = try? FileManager.default.contentsOfDirectory(atPath: dir) else { continue }
            for f in files {
                let path = (dir as NSString).appendingPathComponent(f)
                var isDir: ObjCBool = false
                FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
                if !isDir.boolValue && FileManager.default.isReadableFile(atPath: path) {
                    return path
                }
            }
        }
        return nil
    }

    @objc private func loadLog() {
        guard let path = findReadableLog() else {
            currentLogPath = ""
            statusLabel.text = "No readable log files"
            textView.text = "Cannot access system logs.\nSandbox escape required."
            return
        }
        currentLogPath = path
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            statusLabel.text = "read error"
            return
        }
        let maxShow = 150_000
        let show = data.count > maxShow ? data.suffix(maxShow) : data
        textView.text = String(data: show, encoding: .utf8) ?? "(binary)"
        lastLogSize = UInt64(data.count)
        statusLabel.text = "\((path as NSString).lastPathComponent): \(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))"
        scrollToBottom()
    }

    private func tailLog() {
        guard !currentLogPath.isEmpty,
              let attrs = try? FileManager.default.attributesOfItem(atPath: currentLogPath),
              let size = attrs[.size] as? UInt64, size > lastLogSize,
              let fh = FileHandle(forReadingAtPath: currentLogPath) else { return }
        fh.seek(toFileOffset: lastLogSize)
        let newData = fh.readDataToEndOfFile()
        fh.closeFile()
        if let text = String(data: newData, encoding: .utf8), !text.isEmpty {
            textView.text += text
            lastLogSize = size
            scrollToBottom()
        }
    }

    @objc private func reload() { loadLog() }

    @objc private func scrollToBottom() {
        guard !textView.text.isEmpty else { return }
        textView.scrollRangeToVisible(NSRange(location: max(0, textView.text.count - 1), length: 1))
    }

    @objc private func shareLog() {
        present(UIActivityViewController(activityItems: [textView.text ?? ""], applicationActivities: nil), animated: true)
    }
}
