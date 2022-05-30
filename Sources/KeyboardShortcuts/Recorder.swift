import SwiftUI

@available(macOS 10.15, *)
extension KeyboardShortcuts {
	private struct _Recorder: NSViewRepresentable { // swiftlint:disable:this type_name
		typealias NSViewType = RecorderCocoa

		let name: Name
		let onChange: ((_ shortcut: Shortcut?) -> Void)?
		/// Adjust AppKit properties of NSViewType
		let configuration: ((NSViewType) -> Void)?

		func makeNSView(context: Context) -> NSViewType {
			let view = NSViewType(for: name, onChange: onChange)
			configuration?(view)
			return view
		}

		func updateNSView(_ nsView: NSViewType, context: Context) {
			nsView.shortcutName = name
			configuration?(nsView)
		}
	}

	/**
	A SwiftUI `View` that lets the user record a keyboard shortcut.

	You would usually put this in your preferences window.

	It automatically prevents choosing a keyboard shortcut that is already taken by the system or by the app's main menu by showing a user-friendly alert to the user.

	It takes care of storing the keyboard shortcut in `UserDefaults` for you.

	```swift
	import SwiftUI
	import KeyboardShortcuts

	struct SettingsScreen: View {
		var body: some View {
			Form {
				KeyboardShortcuts.Recorder("Toggle Unicorn Mode:", name: .toggleUnicornMode)
			}
		}
	}
	```
	*/
	public struct Recorder<Label: View>: View { // swiftlint:disable:this type_name
		private let name: Name
		private let onChange: ((Shortcut?) -> Void)?
		private let configuration: ((KeyboardShortcuts.RecorderCocoa) -> Void)?
		private let hasLabel: Bool
		private let label: Label

		init(
			for name: Name,
			onChange: ((Shortcut?) -> Void)? = nil,
			configuration: ((KeyboardShortcuts.RecorderCocoa) -> Void)? = nil,
			hasLabel: Bool,
			@ViewBuilder label: () -> Label
		) {
			self.name = name
			self.onChange = onChange
			self.configuration = configuration
			self.hasLabel = hasLabel
			self.label = label()
		}

		public var body: some View {
			if hasLabel {
				_Recorder(
					name: name,
					onChange: onChange,
					configuration: configuration
				)
					.formLabel {
						label
					}
			} else {
				_Recorder(
					name: name,
					onChange: onChange,
					configuration: configuration
				)
			}
		}
	}
}

@available(macOS 10.15, *)
extension KeyboardShortcuts.Recorder where Label == EmptyView {
	/**
	- Parameter name: Strongly-typed keyboard shortcut name.
	- Parameter onChange: Callback which will be called when the keyboard shortcut is changed/removed by the user. This can be useful when you need more control. For example, when migrating from a different keyboard shortcut solution and you need to store the keyboard shortcut somewhere yourself instead of relying on the built-in storage. However, it's strongly recommended to just rely on the built-in storage when possible.
	- Parameter configuration: Callback which will be called whenever the AppKit `RecorderCocoa` control will be created or updated.
	*/
	public init(
		for name: KeyboardShortcuts.Name,
		onChange: ((KeyboardShortcuts.Shortcut?) -> Void)? = nil,
		configuration: ((KeyboardShortcuts.RecorderCocoa) -> Void)? = nil
	) {
		self.init(
			for: name,
			onChange: onChange,
			configuration: configuration,
			hasLabel: false
		) {}
	}
}

@available(macOS 10.15, *)
extension KeyboardShortcuts.Recorder where Label == Text {
	/**
	- Parameter title: The title of the keyboard shortcut recorder, describing its purpose.
	- Parameter name: Strongly-typed keyboard shortcut name.
	- Parameter onChange: Callback which will be called when the keyboard shortcut is changed/removed by the user. This can be useful when you need more control. For example, when migrating from a different keyboard shortcut solution and you need to store the keyboard shortcut somewhere yourself instead of relying on the built-in storage. However, it's strongly recommended to just rely on the built-in storage when possible.
	- Parameter configuration: Callback which will be called whenever the AppKit `RecorderCocoa` control will be created or updated.
	*/
	public init(
		_ title: String,
		name: KeyboardShortcuts.Name,
		onChange: ((KeyboardShortcuts.Shortcut?) -> Void)? = nil,
		configuration: ((KeyboardShortcuts.RecorderCocoa) -> Void)? = nil
	) {
		self.init(
			for: name,
			onChange: onChange,
			configuration: configuration,
			hasLabel: true
		) {
			Text(title)
		}
	}
}

@available(macOS 10.15, *)
extension KeyboardShortcuts.Recorder {
	/**
	- Parameter name: Strongly-typed keyboard shortcut name.
	- Parameter onChange: Callback which will be called when the keyboard shortcut is changed/removed by the user. This can be useful when you need more control. For example, when migrating from a different keyboard shortcut solution and you need to store the keyboard shortcut somewhere yourself instead of relying on the built-in storage. However, it's strongly recommended to just rely on the built-in storage when possible.
	- Parameter configuration: Callback which will be called whenever the AppKit `RecorderCocoa` control will be created or updated.
	- Parameter label: A view that describes the purpose of the keyboard shortcut recorder.
	*/
	public init(
		for name: KeyboardShortcuts.Name,
		onChange: ((KeyboardShortcuts.Shortcut?) -> Void)? = nil,
		configuration: ((KeyboardShortcuts.RecorderCocoa) -> Void)? = nil,
		@ViewBuilder label: () -> Label
	) {
		self.init(
			for: name,
			onChange: onChange,
			configuration: configuration,
			hasLabel: true,
			label: label
		)
	}
}

@available(macOS 10.15, *)
struct SwiftUI_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			KeyboardShortcuts.Recorder(for: .init("xcodePreview"))
				.environment(\.locale, .init(identifier: "en"))
			KeyboardShortcuts.Recorder(for: .init("xcodePreview"))
				.environment(\.locale, .init(identifier: "zh-Hans"))
			KeyboardShortcuts.Recorder(for: .init("xcodePreview"))
				.environment(\.locale, .init(identifier: "ru"))
		}
	}
}
