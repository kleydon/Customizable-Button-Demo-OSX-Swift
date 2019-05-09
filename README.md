# Customizable-Button-Demo-OSX-Swift

A customizable button class for cocoa / OSX, written in Swift. 

Permits customizing, via InterfaceBuilder or code:

* Button color (normal and pressed)
* Border color (normal and pressed)
* Icon color (normal and pressed) - Supports monochrome images.
* Icon image (normal and pressed)
* Text color (normal and pressed)
* Border Radius (together or one at a time)
* Roll-over/hover highlighting
* Glow color
* Glow radius



# Usage:

1. Add the QXButton.swift class to your codebase.
1. Using InterfaceBuilder, drag a button to a storyboard
2. From InterfaceBuilder's Attributes Inspector, change the style of the button to "Square"
3. From InterfaceBuilder's Identity Inspector, set the class to "QXButton"
4. Returning to the Attribute Inspector, controls will appear for button color, etc.
5. Configure and connect your QXButton as you would a standard NSButton.


# Implementation:

NOTE: The relative positioning of text and image (when button includes both) is still flakey.
