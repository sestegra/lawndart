// Auto-generated from todo_component.html.
// DO NOT EDIT.

library x_todo_item;

import 'dart:html' as autogenerated;
import 'dart:svg' as autogenerated_svg;
import 'package:web_ui/web_ui.dart' as autogenerated;
import 'package:web_ui/web_ui.dart';
import 'models.dart';
import 'app.dart' as app;



class TodoItemComponent extends WebComponent {
  /** Autogenerated from the template. */

  /** CSS class constants. */
  static Map<String, String> _css = {};

  /**
   * Shadow root for this component. We use 'var' to allow simulating shadow DOM
   * on browsers that don't support this feature.
   */
  var _root;
  autogenerated.InputElement __e6;
  autogenerated.LabelElement __e9;
  autogenerated.SpanElement __e8;
  autogenerated.Template __t;

  TodoItemComponent.forElement(e) : super.forElement(e);

  void created_autogenerated() {
    _root = createShadowRoot();
    __t = new autogenerated.Template(_root);
    if (_root is autogenerated.ShadowRoot) _root.applyAuthorStyles = true;
    _root.innerHtml = '''
        <label class="" id="__e-9">
          <input type="checkbox" id="__e-6">
          <span id="__e-8"></span>
        </label>
      ''';
    __e9 = _root.query('#__e-9');
    __e6 = __e9.query('#__e-6');
    __t.listen(__e6.onChange, ($event) { toggle(); });
    __t.oneWayBind(() =>  isChecked , (e) { __e6.checked = e; }, false, false);
    __e8 = __e9.query('#__e-8');
    var __binding7 = __t.contentBind(() =>  todo.actionItem , false);
    __e8.nodes.add(__binding7);
    __t.bindClass(__e9, () =>  completeClass , false);
    __t.create();
  }

  void inserted_autogenerated() {
    __t.insert();
  }

  void removed_autogenerated() {
    __t.remove();
    __t = __e9 = __e6 = __e8 = null;
  }

  void composeChildren() {
    super.composeChildren();
    if (_root is! autogenerated.ShadowRoot) _root = this;
  }

  /** Original code from the component. */

  TodoItem todo;
  
  toggle() {
    todo.toggle();
    app.storeAllTodos();
  }
  
  bool get isChecked => todo.complete;
  
  String get completeClass => todo.complete ? 'completed' : '';
}
//@ sourceMappingURL=todo_component.dart.map