//
//  UITextViewWrapper.swift
//  WorldDex
//
//  Created by Anthony Qin on 10/28/23.
//

import SwiftUI
import UIKit

struct UITextViewWrapper: UIViewRepresentable {
    @Binding var text: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.textColor = .black
        textView.backgroundColor = UIColor(named: "theme1")
        textView.font = UIFont(name: "Avenir", size: 20)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextViewWrapper

        init(_ parent: UITextViewWrapper) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            textView.selectedRange = NSRange(location: textView.text.count, length: 0)
        }

    }
}

