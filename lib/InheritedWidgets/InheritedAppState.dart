import 'package:otsu/resources.dart';

class InheritedAppState extends InheritedWidget {
  final IconDatabase iconDb;
  final String dir;
  final GlobalKey key;

  const InheritedAppState({
    this.iconDb,
    this.dir,
    this.key,
    Widget child,
  }) : super(child: child);

  static InheritedAppState of(BuildContext context) => context.inheritFromWidgetOfExactType(InheritedAppState);

  @override
  bool updateShouldNotify(InheritedAppState oldWidget) => true;
}