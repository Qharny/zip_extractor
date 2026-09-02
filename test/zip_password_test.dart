import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:test/test.dart';
import 'package:zip_extractor/components/zip_password.dart';

// A ZipCrypto-encrypted archive (`zip -P testpass123 fixture.zip note.txt`,
// content "hello test\n"), embedded so the test doesn't depend on a `zip`
// binary being on PATH in CI.
const _zipCryptoFixtureB64 =
    'UEsDBAoACQAAAEyqIl0ANYQMFwAAAAsAAAAIABwAbm90ZS50eHRVVAkAA5+SmGqfkphqdXgLAAEE'
    '6AMAAAToAwAAUvSqomC1Y2XUroTKrs+pgu9HQxsiL3dQSwcIADWEDBcAAAALAAAAUEsBAh4DCgAJ'
    'AAAATKoiXQA1hAwXAAAACwAAAAgAGAAAAAAAAQAAALSBAAAAAG5vdGUudHh0VVQFAAOfkphqdXgL'
    'AAEE6AMAAAToAwAAUEsFBgAAAAABAAEATgAAAGkAAAAAAA==';

Uint8List _zipCryptoFixture() => base64.decode(_zipCryptoFixtureB64);

Uint8List _buildPlainZip() {
  final archive = Archive()..addFile(ArchiveFile.string('a.txt', 'plain'));
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

Uint8List _buildAesZip(String password) {
  final archive = Archive()..addFile(ArchiveFile.string('a.txt', 'secret'));
  return Uint8List.fromList(ZipEncoder(password: password).encode(archive));
}

void main() {
  group('isZipEncrypted', () {
    test('false for a plain zip', () {
      expect(isZipEncrypted(_buildPlainZip()), isFalse);
    });

    test('true for a ZipCrypto-encrypted zip', () {
      expect(isZipEncrypted(_zipCryptoFixture()), isTrue);
    });

    test('true for an AES-encrypted zip', () {
      expect(isZipEncrypted(_buildAesZip('correct horse')), isTrue);
    });
  });

  group('passwordAppearsCorrect — ZipCrypto', () {
    late Uint8List bytes;
    setUp(() => bytes = _zipCryptoFixture());

    test('accepts the correct password', () {
      final decoder = ZipDecoder();
      final archive = decoder.decodeBytes(bytes, password: 'testpass123');
      expect(
        passwordAppearsCorrect(
          bytes,
          decoder.directory,
          archive,
          'testpass123',
        ),
        isTrue,
      );
    });

    test('rejects a wrong password without throwing', () {
      final decoder = ZipDecoder();
      final archive = decoder.decodeBytes(bytes, password: 'wrong');
      expect(
        passwordAppearsCorrect(bytes, decoder.directory, archive, 'wrong'),
        isFalse,
      );
    });
  });

  group('passwordAppearsCorrect — AES', () {
    test('accepts the correct password', () {
      final bytes = _buildAesZip('correct horse');
      final decoder = ZipDecoder();
      final archive = decoder.decodeBytes(bytes, password: 'correct horse');
      expect(
        passwordAppearsCorrect(
          bytes,
          decoder.directory,
          archive,
          'correct horse',
        ),
        isTrue,
      );
    });

    test('rejects a wrong password without throwing', () {
      final bytes = _buildAesZip('correct horse');
      final decoder = ZipDecoder();
      final archive = decoder.decodeBytes(bytes, password: 'battery staple');
      expect(
        passwordAppearsCorrect(
          bytes,
          decoder.directory,
          archive,
          'battery staple',
        ),
        isFalse,
      );
    });
  });
}
