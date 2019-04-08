import 'package:otsu/resources.dart';

class InheritedAppState extends InheritedWidget {
  final IconDatabase iconDb;

  const InheritedAppState({
    this.iconDb,
    Widget child,
  }) : super(child: child);

  static InheritedAppState of(BuildContext context) => context.inheritFromWidgetOfExactType(InheritedAppState);

  @override
  bool updateShouldNotify(InheritedAppState oldWidget) => true;
}