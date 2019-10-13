import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';

class DbInstance {


 static Future printRecord() async {
    Database db = await databaseFactoryMemoryFs.openDatabase("record_demo.db");
    var store = intMapStoreFactory.store("my_store");

    var key = await store.add(db, {"name": "ugly"});
    var record = await store.record(key).getSnapshot(db);
    record =
        (await store.find(db, finder: Finder(filter: Filter.byKey(record.key))))
            .first;
    print(record);
  }
}