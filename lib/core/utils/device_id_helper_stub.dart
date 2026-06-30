// Stub untuk platform non-web (mobile/desktop).
// Tanpa shared_preferences, device ID tidak bisa dipersist —
// dikembalikan string kosong agar caller menghasilkan ID baru setiap sesi.
String getPersistedDeviceIdImpl() => '';
void persistDeviceIdImpl(String id) {}
