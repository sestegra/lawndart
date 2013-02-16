//Copyright 2012 Seth Ladd
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

part of lawndart;

class IndexedDbAdapter<K, V> extends Store<K, V> {
  
  String dbName;
  int version;
  idb.Database _db;
  String storeName;
  
  IndexedDbAdapter(this.dbName, this.storeName, {this.version: 1}) {
    if (version == null) {
      throw new ArgumentError("version must not be null");
    }
  }
  
  Future open() {
    return window.indexedDB.open(dbName, version: version,
        onUpgradeNeeded: (e) {
          _db = e.target.result;
          if (!_db.objectStoreNames.contains(storeName)) {  
            _db.createObjectStore(storeName);
          }
        })
        .then((db) {
          _db = db;
          _isOpen = true;
          return true;
        });
  }
  
  @override
  Future _removeByKey(K key) {
    return _doCommand((idb.ObjectStore store) => store.delete(key), (e) => true);
  }
  
  @override
  Future<K> _save(V obj, K key) {
    return _doCommand((idb.ObjectStore store) => store.$dom_put(obj, key),
        (e) => true);
  }
  
  @override
  Future<V> _getByKey(K key) {
    return _doCommand((idb.ObjectStore store) => store.$dom_getObject(key),
        (req) => req.result, 'readonly');
  }
  
  @override
  Future _nuke() {
    return _doCommand((idb.ObjectStore store) => store.clear(), (e) => true);
  }
  
  _doCommand(idb.Request requestCommand(idb.ObjectStore store),
             dynamic onComplete(idb.Request req),
             [String txnMode = 'readwrite']) {
    var completer = new Completer();
    var trans = _db.transaction(storeName, txnMode);
    var store = trans.objectStore(storeName);
    var request = requestCommand(store);
    trans.onComplete.listen((e) => completer.complete(onComplete(request)));
    request.onError.listen((e) => completer.completeError(e));
    return completer.future;
  }
  
  _doGetAll(dynamic onCursor(idb.CursorWithValue cursor)) {
    var completer = new Completer<Collection<V>>();
    var trans = _db.transaction(storeName, 'readonly');
    var store = trans.objectStore(storeName);
    var values = new Queue<V>();
    // Get everything in the store.
    store.openCursor(autoAdvance: true).listen(
        (cursor) => values.add(onCursor(cursor)),
        onDone: () => completer.complete(values),
        onError: (e) => completer.completeError(e));
    return completer.future;
  }
  
  @override
  Future<Iterable<V>> _all() {
    return _doGetAll((idb.CursorWithValue cursor) => cursor.value);
  }

  @override
  Future _batch(Map<K, V> objs) {
    var futures = <Future>[];
    var completer = new Completer<Collection<V>>();
    
    for (var key in objs.keys) {
      var obj = objs[key];
      futures.add(save(obj, key));
    }
    
    return Future.wait(futures);
  }

  @override
  Future<Iterable<V>> _getByKeys(Iterable<K> keys) {
    return Future.wait(keys.map((key) => getByKey(key)))
        .then((values) => new Future.immediate(values.where((v) => v != null)));
  }

  @override
  Future<bool> _removeByKeys(Iterable<K> keys) {
    var completer = new Completer();
    Future.wait(keys.map((key) => removeByKey(key))).then((_) {
      completer.complete(true);
    });  
    return completer.future;
  }

  @override
  Future<bool> _exists(K key) {
    return getByKey(key).then((value) => value != null);
  }

  @override
  Future<Iterable<K>> _keys() {
    return _doGetAll((idb.CursorWithValue cursor) => cursor.key);
  }
}