import UIKit
import SwiftUI

@objc(CustomShareNavigationController)
class CustomShareNavigationController: UIViewController {
    var shareView: ShareView? = nil
    var context: NSExtensionContext? = nil

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        shareView = ShareView(
            dismissAction: {
                self.context?.completeRequest(returningItems: nil, completionHandler: nil)
                self.dismiss(animated: true, completion: nil)
            },
            cancelAction: {
                self.context?.completeRequest(returningItems: nil, completionHandler: nil)
                self.shareView?.shareViewModel.cancel()
                self.dismiss(animated: true, completion: nil)
            },
            disappearAction: {
                self.context?.completeRequest(returningItems: nil, completionHandler: nil)
            }
        )
        let shareVc = UIHostingController(rootView: shareView)
        self.present(shareVc, animated: true, completion: nil)
    }

    override func beginRequest(with context: NSExtensionContext) {
        self.context = context
        if let item = context.inputItems.first as? NSExtensionItem,
           let attachments = item.attachments,
           let itemProvider = attachments.first {
            if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { [self] (url, error) in
                    if let url = (url as? URL) {
                        shareView?.shareViewModel.setURL(url.absoluteString)
                    }
                }
            }
            if itemProvider.hasItemConformingToTypeIdentifier("public.plain-text") {
                itemProvider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) { [self] (sharedText, error) in
                    if let sharedText = (sharedText as? String) {
                        shareView?.shareViewModel.setURL(sharedText)
                    }
                }
            }
        }
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
