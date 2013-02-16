library store_tests;

import 'dart:async';
import 'dart:html' as html;
import 'dart:indexed_db';
import 'package:unittest/unittest.dart';
import 'package:lawndart/lawndart.dart';

typedef Store<String, String> StoreGenerator();

run(StoreGenerator generator) {
  Store store;
  
  group('just open', () {
    setUp(() => store = generator());
    
    test('open', () {
      var future = store.open();
      expect(future, completion(true));
    });
  });
  
  group('before open', () {
    setUp(() => store = generator());
    
    test('keys throws stateerror', () {
      expect(() => store.keys(), throwsStateError);
    });
    
    test('save throws stateerror', () {
      expect(() => store.save('key', 'value'), throwsStateError);
    });
    
    test('batch throws stateerror', () {
      expect(() => store.batch({'foo': 'bar'}), throwsStateError);
    });
    
    test('get by key throws stateerror', () {
      expect(() => store.getByKey('foo'), throwsStateError);
    });
    
    test('get by keys throws stateerror', () {
      expect(() => store.getByKeys(['foo']), throwsStateError);
    });
    
    test('exists throws stateerror', () {
      expect(() => store.exists('foo'), throwsStateError);
    });
    
    test('all throws stateerror', () {
      expect(() => store.all(), throwsStateError);
    });
    
    test('remove by key throws stateerror', () {
      expect(() => store.removeByKey('foo'), throwsStateError);
    });
    
    test('remove by keys throws stateerror', () {
      expect(() => store.removeByKeys(['foo']), throwsStateError);
    });
    
    test('nuke throws stateerror', () {
      expect(() => store.nuke(), throwsStateError);
    });
  });
  
  group('with no values', () {
    setUp(() {
      store = generator();
      return store.open().then((_) => store.nuke());
    });
    
    test('keys is empty', () {
      var future = store.keys();
      future.then((keys) {
        expect(keys, hasLength(0));
      });
      expect(future, completes);
    });

    test('get by key return null', () {
      var future = store.getByKey("foo");
      expect(future, completion(null));
    });
    
    test('get by keys return empty collection', () {
      var future = store.getByKeys(["foo"]);
      expect(future, completion(hasLength(0)));
    });
    
    test('save completes', () {
      var future = store.save("key", "value");
      expect(future, completion(true));
    });
    
    test('exists returns false', () {
      var future = store.exists("foo");
      expect(future, completion(false));
    });
    
    test('all is empty', () {
      var future = store.all();
      expect(future, completion(hasLength(0)));
    });
    
    test('remove by key completes', () {
      var future = store.removeByKey("foo");
      expect(future, completes);
    });
    
    test('remove by keys completes', () {
      var future = store.removeByKeys(["foo"]);
      expect(future, completes);
    });
    
    test('nuke completes', () {
      var future = store.nuke();
      expect(future, completes);
    });
    
    test('batch completes', () {
      var future = store.batch({'foo':'bar'});
      expect(future, completes);
    });
  });
  
  group('with a few values', () {
    setUp(() {
      // ensure it's clear for each test, see http://dartbug.com/8157
      store = generator();
      
      return store.open().then((_) => store.nuke())
          .then((_) => store.save("world", "hello"))
          .then((_) => store.save("is fun", "dart"));
    });
    
    test('keys has them', () {
      Future<Iterable> future = store.keys();
      future.then((Iterable keys) {
          expect(keys, hasLength(2));
          expect(keys, contains("hello"));
          expect(keys, contains("dart"));
      });
      expect(future, completes);
    });
    
    test('get by key', () {
      Future future = store.getByKey("hello");
      future.then((value) {
        expect(value, "world");
      });
      expect(future, completes);
    });
    
    test('get by keys', () {
      Future future = store.getByKeys(["hello", "dart"]);
      future.then((values) {
        expect(values, hasLength(2));
        expect(values.contains("world"), true);
        expect(values.contains("is fun"), true);
      });
      expect(future, completes);
    });
    
    test('exists is true', () {
      Future future = store.exists("hello");
      future.then((exists) {
        expect(exists, true);
      });
      expect(future, completes);
    });
    
    test('all has everything', () {
      Future future = store.all();
      future.then((all) {
        expect(all, hasLength(2));
        expect(all.contains("world"), true);
        expect(all.contains("is fun"), true);
      });
      expect(future, completes);
    });
    
    test('remove by key', () {
      Future future = store.removeByKey("hello").then((_) => store.all());
      future.then((remaining) {
        expect(remaining, hasLength(1));
        expect(remaining.contains("world"), false);
        expect(remaining.contains("is fun"), true);
      });
      expect(future, completes);
    });
  });
}

main() {
  group('memory', () {
    run(() => new MemoryAdapter<String, String>());
  });
  
  group('local storage', () {
    run(() => new LocalStorageAdapter<String, String>());
  });
  
  if (html.Database.supported) {
    group('websql', () {
      run(() => new WebSqlAdapter<String, String>('test', 'test'));
    });
  }
  
  if (IdbFactory.supported) {
    group('indexed db', () {
      run(() => new IndexedDbAdapter("test-db", "test-store"));
    });
  }
}