import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Returns true if any entry in the zip is encrypted (general purpose bit 0),
/// covering both traditional ZipCrypto and AES (AE-1/AE-2) entries.
bool isZipEncrypted(Uint8List zipBytes) {
  final directory = ZipDirectory();
  directory.read(InputMemoryStream(zipBytes));
  return directory.fileHeaders.any((h) => h.generalPurposeBitFlag & 0x1 != 0);
}

/// Checks a candidate password against every encrypted entry in [archive]
/// before any file is written to disk.
///
/// ZipCrypto entries are checked directly against the classic PKWARE
/// stream-cipher check byte (the `archive` package itself never validates
/// this, so a wrong password would otherwise decrypt to silent garbage
/// instead of failing). AES entries are verified by forcing a decompression,
/// which the `archive` package validates internally and throws on a wrong
/// password.
///
/// Returns true if the password checks out for every encrypted entry.
bool passwordAppearsCorrect(
  Uint8List zipBytes,
  ZipDirectory directory,
  Archive archive,
  String password,
) {
  for (final header in directory.fileHeaders) {
    if (header.generalPurposeBitFlag & 0x1 == 0) continue; // not encrypted

    if (header.compressionMethod == 99) {
      // AES (AE-1/AE-2): forcing content access triggers the package's own
      // password-check-value comparison, which throws on a wrong password.
      final entry = archive.findFile(header.filename);
      if (entry == null || !entry.isFile) continue;
      try {
        entry.content;
      } catch (_) {
        return false;
      }
    } else {
      final ok = _verifyZipCryptoPassword(zipBytes, header, password);
      if (ok == false) return false;
    }
  }
  return true;
}

/// Verifies [password] against a ZipCrypto-encrypted entry's 1-byte check
/// value, without decrypting or decompressing the entry's content.
///
/// Returns null when the entry isn't ZipCrypto-encrypted or the header data
/// needed to check it isn't available (caller should fall back to trying
/// the full decode/extract and handling any error there).
bool? _verifyZipCryptoPassword(
  Uint8List zipBytes,
  ZipFileHeader header,
  String password,
) {
  if (header.generalPurposeBitFlag & 0x1 == 0) return null;
  if (header.compressionMethod == 99) return null; // AES, not ZipCrypto

  // Walk past the local file header's fixed fields to the start of the
  // encrypted data: signature(4) version(2) flags(2) method(2) time(2)
  // date(2) crc32(4) compSize(4) uncompSize(4) nameLen(2) extraLen(2).
  var offset = header.localHeaderOffset + 4 + 2 + 2 + 2 + 2 + 2 + 4 + 4 + 4;
  if (offset + 4 > zipBytes.length) return null;

  final byteData = ByteData.sublistView(zipBytes);
  final nameLen = byteData.getUint16(offset, Endian.little);
  final extraLen = byteData.getUint16(offset + 2, Endian.little);
  offset += 4 + nameLen + extraLen;

  if (offset + 12 > zipBytes.length) return null;

  final keys = <int>[305419896, 591751049, 878082192];

  void updateKeys(int c) {
    keys[0] = getCrc32Byte(keys[0], c) & 0xFFFFFFFF;
    keys[1] = (keys[1] + (keys[0] & 0xff)) & 0xFFFFFFFF;
    keys[1] = (keys[1] * 134775813 + 1) & 0xFFFFFFFF;
    keys[2] = getCrc32Byte(keys[2], (keys[1] >> 24) & 0xff) & 0xFFFFFFFF;
  }

  for (final c in password.codeUnits) {
    updateKeys(c);
  }

  int decryptByte() {
    final temp = (keys[2] & 0xffff) | 2;
    return ((temp * (temp ^ 1)) >> 8) & 0xff;
  }

  var lastDecrypted = 0;
  for (var i = 0; i < 12; i++) {
    final c = zipBytes[offset + i] ^ decryptByte();
    updateKeys(c);
    lastDecrypted = c;
  }

  // The check byte is the high byte of the CRC-32, or of the last-modified
  // time when bit 3 (data descriptor used) means the CRC wasn't known yet
  // at header-write time.
  final expected =
      (header.generalPurposeBitFlag & 0x08) != 0
          ? (header.lastModifiedFileTime >> 8) & 0xff
          : (header.crc32 >> 24) & 0xff;

  return lastDecrypted == expected;
}
