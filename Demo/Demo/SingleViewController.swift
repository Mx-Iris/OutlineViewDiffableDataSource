import AppKit
import SwiftUI
import OutlineViewDiffableDataSource

/// Editor for the single selected item in the sidebar.
final class SingleViewController: NSViewController {

  /// Multiline text editor for the outline contents.
  private lazy var scrollableEditor: NSScrollView = {
    let scrollView = NSTextView.scrollablePlainDocumentContentTextView()
    scrollView.borderType = .lineBorder
    if let textView = scrollView.documentView as? NSTextView {
      textView.textContainerInset = NSMakeSize(8, 8)
      textView.font = .systemFont(ofSize: NSFont.systemFontSize(for: .regular))
    }
    return scrollView
  }()

  /// Sidebar data source.
  private let snapshotBinding: Binding<DiffableDataSourceSnapshot<NSObject>>

  /// Creates a new editor for a single sidebar item.
  init(binding: Binding<DiffableDataSourceSnapshot<NSObject>>) {
    self.snapshotBinding = binding

    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable, message: "IB is denied")
  required init?(coder: NSCoder) {
    fatalError()
  }
}

// MARK: -

extension SingleViewController {

  /// Creates a vertical stack of controls.
  override func loadView() {
    let stackView = NSStackView()
    stackView.orientation = .vertical
    stackView.distribution = .fill
    stackView.addView(scrollableEditor, in: .center)
    stackView.addView(NSButton(title: "Append Item Contents", target: self, action: #selector(appendItemContents(_:))), in: .center)
    stackView.addView(NSButton(title: "Remove Selected Item", target: self, action: #selector(removeSelectedItem(_:))), in: .center)
    stackView.setHuggingPriority(.fittingSizeCompression, for: .horizontal)
    view = stackView
  }
}

// MARK: - Actions

private extension SingleViewController {

  /// Inserts item contents.
  @IBAction func appendItemContents(_ sender: Any?) {
    guard let textView = scrollableEditor.documentView as? NSTextView,
      let selectedItem = representedObject as? MasterOutlineViewItem else { return }
    var snapshot = snapshotBinding.wrappedValue
    snapshot.fillItem(selectedItem, with: textView.string)
    snapshotBinding.wrappedValue = snapshot
  }

  /// Removes selected item.
  @IBAction func removeSelectedItem(_ sender: Any?) {
    guard let selectedItem = representedObject as? MasterOutlineViewItem else { return }
    var snapshot = snapshotBinding.wrappedValue
    snapshot.deleteItems([selectedItem])
    snapshotBinding.wrappedValue = snapshot
  }
}
