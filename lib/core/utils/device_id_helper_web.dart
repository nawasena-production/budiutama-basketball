// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

const _kStorageKey = '_bu_device_id';

String getPersistedDeviceIdImpl() =>
    html.window.localStorage[_kStorageKey] ?? '';

void persistDeviceIdImpl(String id) =>
    html.window.localStorage[_kStorageKey] = id;
