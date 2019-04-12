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

final String tableIcon      = "Icon";
final String idTag          = "idcolumn";
final String nameTag        = "namecolumn";
final String pathTag        = "pathcolum";
final String xTag           = "xcolumn";
final String yTag           = "ycolumn";
final String embeddedTag    = "embeddedcolumn";
final String pinnedTag      = "pincolumn";
final String scaleTag       = "scalecolumn";
final String activeTag      = "activecolumn";
final String isStoredTag    = "isstoredcolumn";
final String storedIdTag    = "storedidcolumn";
final String isFolderTag    = "isfoldercolumn";

class SavedIcon {
  int id;
  String iconName;
  String iconPath;
  double x;
  double y;
  bool embedded;
  bool pinned;
  double scale;
  bool active;
  bool isStored;
  int storedId;
  bool isFolder;

  SavedIcon();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      nameTag:      iconName,
      pathTag:      iconPath,
      xTag:         x,
      yTag:         y,
      embeddedTag:  embedded == true ? 1 : 0,
      pinnedTag:    pinned   == true ? 1 : 0,
      scaleTag:     scale,
      idTag:        id,
      activeTag:    active   == true ? 1 : 0,
      isStoredTag:  isStored == true ? 1 : 0,
      storedIdTag:  storedId,
      isFolderTag:  isFolder == true ? 1 : 0,
    };

    if (id == null) {
      map[idTag]    = null;
    }

    return map;
  }

  SavedIcon.fromMap(Map<String, dynamic> map) {
    id        = map[idTag] as int;
    iconName  = map[nameTag] as String;
    iconPath  = map[pathTag] as String;
    x         = map[xTag] as double;
    y         = map[yTag] as double;
    embedded  = map[embeddedTag] == 1;
    pinned    = map[pinnedTag] == 1;
    scale     = map[scaleTag] as double;
    active    = map[activeTag] == 1;
    isStored  = map[isStoredTag] == 1;
    storedId  = map[storedIdTag] as int;
    isFolder  = map[isFolderTag] == 1;
  }
}