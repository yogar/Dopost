//
//  AppDelegate.swift
//  Dopost
//
//  Created by Егор Пехота on 10.02.2022.
//

import Foundation
import AppKit
import Combine
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var cancellable: AnyCancellable!
    
    override init() {
        super.init()
        KeyboardShortcuts.onKeyUp(for: .postData, action: { [self] in
            launchDataTaskPublisher()
        })
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusBarItem()
        setupMenuItems()
    }
    
    private func setupStatusBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "arrow.up.doc.fill", accessibilityDescription: "Post my clipboard")
        }
    }
    
    private func setupMenuItems() {
        let menu = NSMenu()
        
        let post = NSMenuItem(title: "Post my clipboard", action: #selector(didTapPost) , keyEquivalent: "")
        menu.addItem(post)
        
        statusItem.menu = menu
    }
    
    @objc private func didTapPost() {
        launchDataTaskPublisher()
    }
    
    func launchDataTaskPublisher() {
        cancellable = makeDataTaskPublisher()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        print("Successfully fetched url")
                    }
                }, receiveValue: { value in
                    NSWorkspace.shared.open(NSURL(string: value)! as URL)
                }
            )
    }
    
    private func makeDataTaskPublisher() -> AnyPublisher<String,URLError> {
        let url = URL(string: "http://example.com")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("text/markdown", forHTTPHeaderField: "Content-Type")
        
        let pastboardData = NSPasteboard.general.pasteboardItems?.first?.data(forType: .string)
        request.httpBody = pastboardData
        
        let urlPublisher = URLSession.shared
            .dataTaskPublisher(for: request)
            .map { data, response -> String in
                let httpResponse = response as! HTTPURLResponse
                switch httpResponse.statusCode {
                case 200, 201:
                    print("Good response code: \(httpResponse.statusCode)")
                    let url = String(decoding: data, as: UTF8.self)
                    return url
                default:
                    print("Bad server response: \(httpResponse.statusCode)")
                    return "Error"
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return urlPublisher
    }
}

