// Stub file for dart:io when compiling for web
// This file provides empty implementations to satisfy the compiler

class Directory {
  static Directory get current => throw UnsupportedError('Directory not available on web');
  Directory(this.path);
  final String path;
  Directory get parent => throw UnsupportedError('Directory not available on web');
}

class File {
  File(this.path);
  final String path;
  Future<bool> exists() => throw UnsupportedError('File not available on web');
  Future<String> readAsString() => throw UnsupportedError('File not available on web');
}

