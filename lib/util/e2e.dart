import 'package:hive_flutter/hive_flutter.dart';
import 'package:jam/providers/user_provider.dart';
import 'package:jam/util/e2e_rsa.dart';
import "package:pointycastle/export.dart";

String keysBoxName = "keys";
String ownPrivateKey = "ownPrivate";

Future openKeysBox() async {
  if (!Hive.isBoxOpen(keysBoxName)) {
    await Hive.openBox<String>(keysBoxName);
  }
}

void deleteKeysBox() {
  Box<String> box = Hive.box<String>(keysBoxName);
  box.deleteFromDisk();
}

/// Returns public key pem file
Future<String> initializeEncryption() async {
  // create own key pair
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> key = generateKeyPair();
  // save private key
  if (!Hive.isBoxOpen(keysBoxName)) {
    await Hive.openBox<String>(keysBoxName);
  }
  Box<String> box = Hive.box<String>(keysBoxName);
  box.put(ownPrivateKey, encodeRSAPrivateKeyToPem(key.privateKey));
  return encodeRSAPublicKeyToPem(key.publicKey);
}

void addPublicKey(String userId, String publicKeyPem) {
  Box<String> box = Hive.box<String>(keysBoxName);
  box.put(userId, publicKeyPem);
}

/// Returns null if there is no public key for given user
String? encryptMessage(String plaintext, String userId) {
  Box<String> box = Hive.box<String>(keysBoxName);
  String? publicPem = box.get(userId);
  if (publicPem == null) {
    print("public key not found for user id: " + userId);
    return null;
  }
  RSAPublicKey publicKey = rsaPublicKeyFromPem(publicPem);
  return encrypt(plaintext, publicKey);
}

/// Logs out if there is no private key for current user
String? decryptMessage(String encryptedText) {
  Box<String> box = Hive.box<String>(keysBoxName);
  String? privatePem = box.get(ownPrivateKey);
  if (privatePem == null) {
    print("private key not found for current user, logging out");
    logout();
    return null;
  }
  RSAPrivateKey privateKey = rsaPrivateKeyFromPem(privatePem);
  return decrypt(encryptedText, privateKey);
}
