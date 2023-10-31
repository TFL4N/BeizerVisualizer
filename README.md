# BeizerVisualizer
A macOS application for visualizing how a Bézier Curve is constructed

![Example Gif](/Examples/Screen_Recording_Example.gif)

## Features
* Drag and drop control points
* Animation shows intermediary lines used to construct
* Uses GMP (GNU Multiple Precision) to calculate positions
* Utilizes NSDocument to archive curves

## "I actually managed to build and run your application"
Sorted out the BigNumber, amazing! Try the opening the curve in /Example (File->Open) or create a new curve (File->New).  Click and drag the red circles to adjust the curve. Then click animate. (When creating a new curve, all of the control points are located at the origin, overlapping each other.  Drag all of those into position)

# Issues/ Upgrades
* Use better default curve for new documents
* Decouple from BigNumber project
* Add support for more control points
* Zoom on renderer view uses trackpad pinch gesture, add desktop solution for keyboard and mouse 
