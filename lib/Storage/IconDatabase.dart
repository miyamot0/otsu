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

import 'package:otsu/resources.dart';
import 'package:path/path.dart' show join;

class IconDatabase
{
  Database db;
  SharedPreferences settings;

  /// Open database
  /// 
  /// 
  Future open() async {    
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "icon.db");  

    loadSettings();

    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}

    try {
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
    } catch (_) {}
  }

  /// Load settings
  /// 
  /// 
  Future<BoardSettings> loadSettings() async {
    settings = settings ?? await SharedPreferences.getInstance();

    bool checkIsInSingleMode    = settings.getBool('isInSingleMode') ?? true;
    bool checkIsAutoSpeaking    = settings.getBool('isAutoSpeaking') ?? false;
    bool checkIsAutoDeselecting = settings.getBool('isAutoDeselecting') ?? true;

    return BoardSettings(
      checkIsInSingleMode:    checkIsInSingleMode,
      checkIsAutoSpeaking:    checkIsAutoSpeaking,
      checkIsAutoDeselecting: checkIsAutoDeselecting,
    );
  }

  /// Save settings
  ///
  ///
  Future<BoardSettings> saveSettings(BoardSettings currentSettings) async {
    settings = settings ?? await SharedPreferences.getInstance();

    await settings.setBool('isInSingleMode',    currentSettings.checkIsInSingleMode);
    await settings.setBool('isAutoSpeaking',    currentSettings.checkIsAutoSpeaking);
    await settings.setBool('isAutoDeselecting', currentSettings.checkIsAutoDeselecting);

    return currentSettings;
  }

  /// Insert into database
  ///
  ///
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

  /// Get icon from database
  /// 
  /// 
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

  /// Get icons from database
  /// 
  /// 
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

  /// Get icons from database
  /// 
  /// 
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

  /// Delete icon from db
  /// 
  /// 
  Future<int> delete(int id) async {
    return await db.delete(tableIcon, where: "$idTag = ?", whereArgs: [id]);
  }

  /// Delete folder and contents
  /// 
  /// 
  Future<int> deleteFolder(int id) async {
    await db.delete(tableIcon, where: "$idTag = ?", whereArgs: [id]);

    return await db.delete(tableIcon, where: "$storedIdTag = ?", whereArgs: [id]); 
  }

  /// Update icon
  /// 
  /// 
  Future<int> update(SavedIcon savedIcon) async {
    //debugPrint("Update: id: ${savedIcon.id}");
    
    return await db.update(tableIcon, savedIcon.toMap(), where: "$idTag = ?", whereArgs: [savedIcon.id]);
  }

  /// Clear all icons
  /// 
  /// 
  Future<int> clearIcons() async {
    return await db.delete(tableIcon, where: null);
  }

  /// Close database
  /// 
  /// 
  Future close() async => db.close();
}
