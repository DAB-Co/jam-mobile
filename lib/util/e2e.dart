import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/util/e2e_rsa.dart';
import "package:pointycastle/export.dart";

String keysBoxName = "keys";

Future openKeysBox() async {
  if (!Hive.isBoxOpen(keysBoxName)) {
    await Hive.openBox<String>(keysBoxName);
  }
}

void saveOwnKeys(AsymmetricKeyPair<PublicKey, PrivateKey> ownKey) {
  Box<String> box = Hive.box<String>(keysBoxName);
  box.put("ownPrivate", ownKey.privateKey.toString());
}

Future<String> encode(String plaintext) async {
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> key = generateKeyPair();
  String publicPem = encodeRSAPublicKeyToPem(key.publicKey);
  print(publicPem);
  RSAPublicKey translated = rsaPublicKeyFromPem(publicPem);
  print(encodeRSAPublicKeyToPem(translated));
  String privatePem = encodeRSAPrivateKeyToPem(key.privateKey);
  print(privatePem);
  RSAPrivateKey translatedp = rsaPrivateKeyFromPem(publicPem);
  print(encodeRSAPrivateKeyToPem(translatedp));
  String result = encrypt(plaintext, key.publicKey);
  print(result);
  String decoded = decrypt(result, key.privateKey);
  print(decoded);
  return result;
}
