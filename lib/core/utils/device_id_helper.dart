import 'device_id_helper_stub.dart'
    if (dart.library.html) 'device_id_helper_web.dart';

/// Ambil device ID yang telah dipersist (kosong jika belum ada).
String getPersistedDeviceId() => getPersistedDeviceIdImpl();

/// Simpan device ID ke storage persisten.
void persistDeviceId(String id) => persistDeviceIdImpl(id);
