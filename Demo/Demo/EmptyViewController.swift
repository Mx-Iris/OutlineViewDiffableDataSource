import AppKit
import SwiftUI
import OutlineViewDiffableDataSource

/// The number of controls for an empty outline view selection.
final class EmptyViewController: NSViewController {

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
  private var snapshotBinding: Binding<DiffableDataSourceSnapshot<NSObject>>

  /// Creates a new editor for sidebar contents.
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

extension EmptyViewController {

  /// Creates a vertical stack of controls.
  override func loadView() {
    let stackView = NSStackView()
    stackView.orientation = .vertical
    stackView.distribution = .fill
    stackView.addView(scrollableEditor, in: .center)
    stackView.addView(NSButton(title: "Fill Sidebar", target: self, action: #selector(fillSidebar(_:))), in: .center)
    stackView.addView(NSButton(title: "Copy From Sidebar", target: self, action: #selector(copyFromSidebar(_:))), in: .center)
    stackView.addView(NSButton(title: "Expand All Items", target: nil, action: #selector(MasterViewController.expandAllItems(_:))), in: .center)
    stackView.addView(NSButton(title: "Collapse All Items", target: nil, action: #selector(MasterViewController.collapseAllItems(_:))), in: .center)
    stackView.setHuggingPriority(.fittingSizeCompression, for: .horizontal)
    view = stackView
  }

  /// Assigns initial text contents.
  override func viewDidLoad() {
    super.viewDidLoad()

    guard let textView = scrollableEditor.documentView as? NSTextView, textView.string.isEmpty else { return }
    textView.string = """
      Parent 1 / Child 11
      Parent 1 / Child 12
      Parent 1 / Child 13
      Parent 2
      Parent 2 / Child 21
      Child 21 / Leaf 211
      Child 21 / Leaf 212
      Parent 3 / Child 31
      Parent 3 / Child 32
      Parent 3 / Child 33
      """
  }
}

// MARK: - Actions

private extension EmptyViewController {

  /// Replaces the whole tree with the given contents.
  @IBAction func fillSidebar(_ sender: Any?) {
    guard let textView = scrollableEditor.documentView as? NSTextView else { return }
    var snapshot: DiffableDataSourceSnapshot<NSObject> = .init()
    snapshot.fillItem(nil, with: textView.string)
    snapshotBinding.wrappedValue = snapshot
  }

  /// Replaces text with sidebar contents.
  @IBAction func copyFromSidebar(_ sender: Any?) {
    guard let textView = scrollableEditor.documentView as? NSTextView else { return }
    let snapshot = snapshotBinding.wrappedValue
    var items: [String] = []
    snapshot.enumerateItems { item, parentItem in
      items.append([
        (parentItem as? GroupOutlineViewItem)?.title ?? (parentItem as? MasterOutlineViewItem)?.title,
        (item as? GroupOutlineViewItem)?.title ?? (item as? MasterOutlineViewItem)?.title,
      ].compactMap { $0 }.joined(separator: " / "))
    }
    textView.string = items.joined(separator: "\n")
  }
}

