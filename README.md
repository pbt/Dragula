<div align="center">

# Dragula

*what if drag and drop was weighted?*

![A demo of Dragula, where depending on the size of the file it's harder or easier to drag](https://github.com/pbt/Dragula/assets/1430300/de6e8b2b-deca-46bb-854e-a25824e5f4ad)

[hi-res video @ 1x speed (**SOUND ON**!)
](https://share.cleanshot.com/Gz9S9WXy
) • [read the blog post](https://www.pbt.dev/blog/dragula/)

</div>

## in Dragula's world:
- the bigger the file selection, the more difficult it is to pick up and drag. *it's as if they had weight!*
- the bigger the items in the folder, the heavier the folder is to drag
- because they're a representation of folders, windows are *also* weighted according to their contents
- finally, fun sound effects play when you finish dragging to reward your effort 

## how to install
unfortunately i am not yet enrolled in the apple developer program (plus i'm not sure 
they would like this app). so for the time being, you will have to clone this repo and 
compile it yourself from Xcode. sorry!

## try the following...
1. dragging an item
2. dragging a folder
3. dragging an icon
4. dragging multiple items (with a *marquee-style selection*, i.e.: click near the first item, press and hold the mouse or trackpad, then drag over all of the items)
5. dragging the window (turn on "Add drag behavior to Finder windows" in settings)
6. turning on "Sound effects" in settings

## caveats
as you might expect there are many, but to name a few:

1. it only works reliably on the icon view
2. the internal model breaks when you do Cmd/Shift selection, because i never coded that in
3. please don't copy my swiftUI code. i don't care if you copy, it's just not good.
4. the event handler seems to randomly go away, making the drag and drop not work. i'm not sure why.

## acknowledgements
none of this would have been possible were it not for my friends at the [recurse center](https://www.recurse.com)

### code
- [LinearMouse](https://github.com/linearmouse/linearmouse)
- [osnr/tap.swift](https://gist.github.com/osnr/23eb05b4e0bcd335c06361c4fabadd6f)
- [Rectangle](https://github.com/rxhanson/Rectangle)

### sounds
- [Metal Impact - Ceramic Piece in Sink by RoganMcDougald](https://freesound.org/people/RoganMcDougald/sounds/260435/)
- also the vine boom sound effect lol

