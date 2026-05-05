#!/usr/bin/swift
import Carbon

guard let allSources = TISCreateInputSourceList(nil, true)?.takeRetainedValue() as? [TISInputSource] else {
	print("error: failed to get input source list")
	exit(1)
}

let targets: Set<String> = [
	"net.mtgto.inputmethod.macSKK",
	"net.mtgto.inputmethod.macSKK.hiragana",
	"net.mtgto.inputmethod.macSKK.katakana",
	"net.mtgto.inputmethod.macSKK.hankakuKatakana",
	"net.mtgto.inputmethod.macSKK.latin",
	"net.mtgto.inputmethod.macSKK.jisx0208Latin",
]

var found = false
for source in allSources {
	guard let ptr = TISGetInputSourceProperty(source, kTISPropertyInputSourceID) else { continue }
	let sourceID = Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
	guard targets.contains(sourceID) else { continue }
	TISEnableInputSource(source)
	TISSelectInputSource(source)
	print("enabled: \(sourceID)")
	found = true
}

if !found {
	print("error: macSKK not found in input source list")
	exit(1)
}
