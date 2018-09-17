/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sqflite/sqflite.dart' show getDatabasesPath;
import 'package:path/path.dart' show join;

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

class BoardSettings {
  bool checkIsInSingleMode;
  bool checkIsAutoSpeaking;
  bool checkIsAutoDeselecting;

  BoardSettings({this.checkIsInSingleMode, 
                 this.checkIsAutoSpeaking, 
                 this.checkIsAutoDeselecting});
}

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
      pinnedTag:    pinned == true ? 1 : 0,
      scaleTag:     scale,
      idTag:        id,
      activeTag:    active == true ? 1 : 0,
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

class IconDatabase
{
  Database db;
  SharedPreferences settings;

  Future open() async {
    
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "icon.db");  

    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
      create table $tableIcon (
        $idTag integer primary key autoincrement, 
        $nameTag text not null, 
        $pathTag text not null, 
        $xTag real not null, 
        $yTag real not null, 
        $embeddedTag integer not null, 
        $pinnedTag integer not null, 
        $scaleTag real not null,
        $activeTag integer not null,
        $isStoredTag integer not null,
        $storedIdTag integer not null,
        $isFolderTag integer not null )
      ''');
    });
  }

  Future<BoardSettings> loadSettings() async {

    if (settings == null)
    {
      settings = await SharedPreferences.getInstance();
    }

    bool checkIsInSingleMode    = settings.getBool('isInSingleMode');
    bool checkIsAutoSpeaking    = settings.getBool('isAutoSpeaking');
    bool checkIsAutoDeselecting = settings.getBool('isAutoDeselecting');

    checkIsInSingleMode     = checkIsInSingleMode     == null ? true  : checkIsInSingleMode;
    checkIsAutoSpeaking     = checkIsAutoSpeaking     == null ? false : checkIsAutoSpeaking;
    checkIsAutoDeselecting  = checkIsAutoDeselecting  == null ? true  : checkIsAutoDeselecting;    

    return BoardSettings(
      checkIsInSingleMode:    checkIsInSingleMode,
      checkIsAutoSpeaking:    checkIsAutoSpeaking,
      checkIsAutoDeselecting: checkIsAutoDeselecting,
    );
  }

  Future<BoardSettings> saveSettings(BoardSettings currentSettings) async {
    await settings.setBool('isInSingleMode',    currentSettings.checkIsInSingleMode);
    await settings.setBool('isAutoSpeaking',    currentSettings.checkIsAutoSpeaking);
    await settings.setBool('isAutoDeselecting', currentSettings.checkIsAutoDeselecting);

    return currentSettings;
  }

  Future<SavedIcon> insert(SavedIcon savedIcon) async {

    if (savedIcon.id == null) {
      savedIcon.id = await db.insert(tableIcon, savedIcon.toMap());
      //debugPrint("insert... id: ${savedIcon.id}");

      return savedIcon;
    }

    int count = Sqflite.firstIntValue(await db.rawQuery("SELECT COUNT(*) FROM $tableIcon WHERE $idTag = ?", [savedIcon.id]));
    //debugPrint("Database: for id ${savedIcon.id}, there were $count matches");

    if (count == 0)
    {
      savedIcon.id = await db.insert(tableIcon, savedIcon.toMap());

      //debugPrint("insert... id: ${savedIcon.id}");      
    }
    else
    {
      savedIcon.id = await db.update(tableIcon, savedIcon.toMap());

      //debugPrint("update... id: ${savedIcon.id}");
    }

    return savedIcon;
  }

  Future<SavedIcon> getSavedIcon(int id) async {
    List<Map> maps = await db.query(tableIcon,
        columns: [idTag, nameTag, pathTag, xTag, yTag, embeddedTag, pinnedTag, scaleTag, activeTag, isStoredTag, storedIdTag, isFolderTag],
        where: "$idTag = ?",
        whereArgs: [idTag]);

    if (maps.length > 0) {
      return new SavedIcon.fromMap(maps.first);
    }

    return null;
  }

  Future<List<SavedIcon>> getSavedIcons() async {
    List<Map> maps = await db.query(tableIcon, columns: [idTag, nameTag, pathTag, xTag, yTag, embeddedTag, pinnedTag, 
                                    scaleTag, activeTag, isStoredTag, storedIdTag, isFolderTag],);

    List<SavedIcon> icons = new List();

    for (int i = 0; i < maps.length; i++) 
    {
      icons.add(SavedIcon.fromMap(maps[i]));
    }

    return icons;
  }

  Future<List<SavedIcon>> getStoredIcons(int id) async {
    List<Map> maps = await db.query(tableIcon,
        columns: [idTag, nameTag, pathTag, xTag, yTag, embeddedTag, pinnedTag, scaleTag, activeTag, isStoredTag, storedIdTag, isFolderTag],
        where: "$storedIdTag = ?",
        whereArgs: [id]);

    List<SavedIcon> icons = new List();

    for (int i = 0; i < maps.length; i++) 
    {
      icons.add(SavedIcon.fromMap(maps[i]));
    }

    return icons;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableIcon, where: "$idTag = ?", whereArgs: [id]);
  }

  Future<int> deleteFolder(int id) async {
    await db.delete(tableIcon, where: "$idTag = ?", whereArgs: [id]);

    return await db.delete(tableIcon, where: "$storedIdTag = ?", whereArgs: [id]); 
  }

  Future<int> update(SavedIcon savedIcon) async {
    //debugPrint("Update: id: ${savedIcon.id}");
    
    return await db.update(tableIcon, savedIcon.toMap(), where: "$idTag = ?", whereArgs: [savedIcon.id]);
  }

  Future<int> clearIcons() async {
    return await db.delete(tableIcon, where: null);
  }

  Future close() async => db.close();

}
