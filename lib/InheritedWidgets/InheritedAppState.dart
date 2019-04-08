import 'package:otsu/resources.dart';

class InheritedAppState extends InheritedWidget {
  final IconDatabase iconDb;
  final String dir;

  const InheritedAppState({
    this.iconDb,
    this.dir,
    Widget child,
  }) : super(child: child);

  static InheritedAppState of(BuildContext context) => context.inheritFromWidgetOfExactType(InheritedAppState);

  @override
  bool updateShouldNotify(InheritedAppState oldWidget) => true;
}