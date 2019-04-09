/* 
    The MIT License

    Copyright September 1, 2018 Shawn Gilroy/Louisiana State University

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

library aacresources;

// Dart imports
export 'dart:io';
export 'dart:async';
export 'dart:io';
export 'dart:convert';
export 'dart:math';

// Flutter imports
export 'package:flutter/material.dart';
export 'package:flutter/scheduler.dart';
export 'package:flutter/services.dart';

// External lib imports
export 'package:image_picker/image_picker.dart';
export 'package:date_format/date_format.dart';
export 'package:package_info/package_info.dart';
export 'package:path_provider/path_provider.dart';

// Models
export 'InheritedWidgets/InheritedAppState.dart';
export 'InheritedWidgets/InheritedFolderState.dart';
export 'InheritedWidgets/InheritedIconState.dart';
export 'InheritedWidgets/InheritedVisualFieldState.dart';
export 'Models/EmbeddedIconModel.dart';
export 'Models/IconType.dart';

// Storage
export 'Storage/IconDatabase.dart';

// Misc
export 'Misc/Utilities.dart';

// Widgets/Views
export 'Controls/AnimatedLetter.dart';
export 'Controls/AnimatedMenu.dart';
export 'Controls/ReactiveFolderWidget.dart';
export 'Controls/ReactiveIconWidget.dart';
export 'Controls/SpeakerObject.dart';
export 'Controls/StripObject.dart';
export 'Controls/VisualFieldWidget.dart';
export 'Dialogs/DialogIconLabel.dart';
export 'Dialogs/DialogEditorIcon.dart';
export 'Dialogs/DialogEditorFolder.dart';
export 'Dialogs/DialogIntro.dart';
export 'Pages/FolderCreator.dart';
export 'Pages/IconCreator.dart';
export 'Pages/TitlePage.dart';
export 'Views/CustomFloatingButtonLocation.dart';
export 'Views/FieldBox.dart';
export 'Views/IconBox.dart';
export 'Views/FolderBox.dart';
export 'Views/PreviewBox.dart';
export 'Views/PreviewIcon.dart';
export 'Views/VisualFieldBox.dart';

// Menus
export 'Menus/EditIconMenu.dart';
export 'Menus/EditFolderMenu.dart';
