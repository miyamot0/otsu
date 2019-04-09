# OpenAAC using Google Flutter (Codename Otsu)

OpenAAC is a Flutter-powered AAC application designed specific to communication in autism spectrum disorders--though extensible to virtually any communication disorder, to a degree. This is built entirely in Google's Flutter to provide a customized interface for learners that is consistent across Android and iOS (and any other platform google supports in the future, using the Skia backend).

Only Android and iOS are actively maintained and under evaluation at this point.

## AAC Features

 - Dynamically add icons and modify text
 - Native, Skia-powered views in iOS/Android
 - Includes single item and frame (i.e., sentence frame) support
 - Dynamically resize, mark icons, and apply other within-stimulus prompts
 - Incorporate images from anywhere, including your camera or from downloaded pictures
 - All boards are locally managed--nothing is ever transmitted

## Images

Title Screen

![Alt text](previews/openaac_intro.gif?raw=true "Title screen")

A "learner" and "therapist" mode is availabe, to minimize distractions

![Alt text](previews/openaac_unlock.gif?raw=true "Unlock screen")

Add as many, or as few, icons to the field as desired

![Alt text](previews/openaac_add.gif?raw=true "Add icons")

Most aspects of icons (e.g., size, text, positioning, dragging) can be modified

![Alt text](previews/openaac_modify.gif?raw=true "Modify icons")

The software accomodates single-icon (i.e., touch to speak) and frame-speech (i.e., create a sentence, then speak it)

![Alt text](previews/openaac_frame.gif?raw=true "Change mode")

## Derivative Works

This project is a derivative work of a peer-reviewed software, under the following licenses:

- [Fast Talker](https://github.com/miyamot0/FastTalker) - MIT - Copyright 2016-2018 Shawn Gilroy. [www.smallnstats.com]
- [Cross-Platform-Communication-App](https://github.com/miyamot0/Cross-Platform-Communication-App) - MIT - Copyright 2016-2017 Shawn Gilroy. [www.smallnstats.com](http://www.smallnstats.com)

This project uses licensed visual images in order to operate:

- [Mulberry Symbols](https://github.com/straight-street/mulberry-symbols) - [CC-BY-SA 2.0.](http://creativecommons.org/licenses/by-sa/2.0/uk/) - Copyright 2008-2012 Garry Paxton. [www.straight-street.com](http://straight-street.com/)

## Dependencies

- package_info - Copyright 2017 The Chromium Authors (BSD-3). [Github](https://github.com/flutter/plugins/tree/master/packages/package_info)
- image_picker - Copyright 2017, Flutter project authors (BSD-3). [Github](https://github.com/flutter/plugins/tree/master/packages/image_picker)
- path_provider - Copyright 2017, Flutter project authors (BSD-3). [Github](https://github.com/flutter/plugins/tree/master/packages/path_provider)
- path - Copyright 2014, Flutter project authors (BSD-3). [Github](https://github.com/dart-lang/path)
- date_format - Copyright (c) 2017, Ravi Teja Gudapati <tejainece@gmail.com> (BSD-3). [Github](https://github.com/tejainece/date_format)
- shared_preferences - Copyright 2017, The Chromium Authors (BSD-3). [Github](https://github.com/flutter/plugins/tree/master/packages/shared_preferences)
- sqflite - Copyright 2017, Alexandre Roux Tekartik (MIT). [Github](https://github.com/tekartik/sqflite)

## Installation

This application can be installed as either an Android or iOS application.  

## Development

This is currently under active development and evaluation.

## Todo

- More options for voice

## License

Copyright 2018, Shawn P. Gilroy (sgilroy1@lsu.edu)/Louisiana State University - MIT