# ATVHue

A WIP Hue client for the Apple TV

Currently Tested and working on tvOS 11.2 & 12.4

Basically in its current state, it gets the color from the screen's center pixel, and then sets a single predefined hue bulb to that color. 

At the moment its not much, but its a start. Expect more in the future :)

To stop refreshing the hue bulb, you will need to uninstall this package (or add some sort of enabled key and respring) 

### NOTE: Make sure to set up the ```hueURL``` in ```ATVTopWindow.h```