import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/asn1.dart';
import "package:pointycastle/export.dart";

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateKeyPair() {
  var keyParams =
      new RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 12);

  var secureRandom = new FortunaRandom();
  var random = new Random.secure();
  List<int> seeds = [];
  for (int i = 0; i < 32; i++) {
    seeds.add(random.nextInt(255));
  }
  secureRandom.seed(new KeyParameter(new Uint8List.fromList(seeds)));

  var rngParams = new ParametersWithRandom(keyParams, secureRandom);
  var k = new RSAKeyGenerator();
  k.init(rngParams);

  AsymmetricKeyPair<PublicKey, PrivateKey> pair = k.generateKeyPair();
  return AsymmetricKeyPair(
      pair.publicKey as RSAPublicKey, pair.privateKey as RSAPrivateKey);
}

String encrypt(String plaintext, RSAPublicKey publicKey) {
  var cipher = new RSAEngine()
    ..init(true, new PublicKeyParameter<RSAPublicKey>(publicKey));
  var cipherText = cipher.process(new Uint8List.fromList(plaintext.codeUnits));

  return new String.fromCharCodes(cipherText);
}

String decrypt(String ciphertext, RSAPrivateKey privateKey) {
  var cipher = new RSAEngine()
    ..init(false, new PrivateKeyParameter<RSAPrivateKey>(privateKey));
  var decrypted = cipher.process(new Uint8List.fromList(ciphertext.codeUnits));

  return new String.fromCharCodes(decrypted);
}

List<String> _chunk(String s, int chunkSize) {
  var chunked = <String>[];
  for (var i = 0; i < s.length; i += chunkSize) {
    var end = (i + chunkSize < s.length) ? i + chunkSize : s.length;
    chunked.add(s.substring(i, end));
  }
  return chunked;
}

const BEGIN_PUBLIC_KEY = '-----BEGIN PUBLIC KEY-----';
const END_PUBLIC_KEY = '-----END PUBLIC KEY-----';
const BEGIN_PRIVATE_KEY = '-----BEGIN PRIVATE KEY-----';
const END_PRIVATE_KEY = '-----END PRIVATE KEY-----';

String encodeRSAPublicKeyToPem(RSAPublicKey publicKey) {
  var algorithmSeq = ASN1Sequence();
  var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
  algorithmSeq.add(ASN1ObjectIdentifier.fromName('rsaEncryption'));
  algorithmSeq.add(paramsAsn1Obj);

  var publicKeySeq = ASN1Sequence();
  publicKeySeq.add(ASN1Integer(publicKey.modulus));
  publicKeySeq.add(ASN1Integer(publicKey.exponent));
  var publicKeySeqBitString =
      ASN1BitString(stringValues: Uint8List.fromList(publicKeySeq.encode()));

  var topLevelSeq = ASN1Sequence();
  topLevelSeq.add(algorithmSeq);
  topLevelSeq.add(publicKeySeqBitString);
  var dataBase64 = base64.encode(topLevelSeq.encode());
  var chunks = _chunk(dataBase64, 64);

  return '$BEGIN_PUBLIC_KEY\n${chunks.join('\n')}\n$END_PUBLIC_KEY';
}

String encodeRSAPrivateKeyToPem(RSAPrivateKey rsaPrivateKey) {
  var version = ASN1Integer(BigInt.from(0));

  var algorithmSeq = ASN1Sequence();
  var algorithmAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList(
      [0x6, 0x9, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0xd, 0x1, 0x1, 0x1]));
  var paramsAsn1Obj = ASN1Object.fromBytes(Uint8List.fromList([0x5, 0x0]));
  algorithmSeq.add(algorithmAsn1Obj);
  algorithmSeq.add(paramsAsn1Obj);

  var privateKeySeq = ASN1Sequence();
  var modulus = ASN1Integer(rsaPrivateKey.n);
  var publicExponent = ASN1Integer(BigInt.parse('65537'));
  var privateExponent = ASN1Integer(rsaPrivateKey.privateExponent);
  var p = ASN1Integer(rsaPrivateKey.p);
  var q = ASN1Integer(rsaPrivateKey.q);
  var dP = rsaPrivateKey.privateExponent! % (rsaPrivateKey.p! - BigInt.from(1));
  var exp1 = ASN1Integer(dP);
  var dQ = rsaPrivateKey.privateExponent! % (rsaPrivateKey.q! - BigInt.from(1));
  var exp2 = ASN1Integer(dQ);
  var iQ = rsaPrivateKey.q!.modInverse(rsaPrivateKey.p!);
  var co = ASN1Integer(iQ);

  privateKeySeq.add(version);
  privateKeySeq.add(modulus);
  privateKeySeq.add(publicExponent);
  privateKeySeq.add(privateExponent);
  privateKeySeq.add(p);
  privateKeySeq.add(q);
  privateKeySeq.add(exp1);
  privateKeySeq.add(exp2);
  privateKeySeq.add(co);
  var publicKeySeqOctetString =
      ASN1OctetString(octets: Uint8List.fromList(privateKeySeq.encode()));

  var topLevelSeq = ASN1Sequence();
  topLevelSeq.add(version);
  topLevelSeq.add(algorithmSeq);
  topLevelSeq.add(publicKeySeqOctetString);
  var dataBase64 = base64.encode(topLevelSeq.encode());
  var chunks = _chunk(dataBase64, 64);
  return '$BEGIN_PRIVATE_KEY\n${chunks.join('\n')}\n$END_PRIVATE_KEY';
}

RSAPublicKey rsaPublicKeyFromPem(String pem) {
  var bytes = _getBytesFromPEMString(pem);
  return _rsaPublicKeyFromDERBytes(bytes);
}

RSAPrivateKey rsaPrivateKeyFromPem(String pem) {
  var bytes = _getBytesFromPEMString(pem);
  return _rsaPrivateKeyFromDERBytes(bytes);
}

RSAPublicKey _rsaPublicKeyFromDERBytes(Uint8List bytes) {
  var asn1Parser = ASN1Parser(bytes);
  var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
  var publicKeySeq;
  if (topLevelSeq.elements![1].runtimeType == ASN1BitString) {
    var publicKeyBitString = topLevelSeq.elements![1] as ASN1BitString;

    var publicKeyAsn =
        ASN1Parser(publicKeyBitString.stringValues as Uint8List?);
    publicKeySeq = publicKeyAsn.nextObject() as ASN1Sequence;
  } else {
    publicKeySeq = topLevelSeq;
  }
  var modulus = publicKeySeq.elements![0] as ASN1Integer;
  var exponent = publicKeySeq.elements![1] as ASN1Integer;

  var rsaPublicKey = RSAPublicKey(modulus.integer!, exponent.integer!);

  return rsaPublicKey;
}

RSAPrivateKey _rsaPrivateKeyFromDERBytes(Uint8List bytes) {
  var asn1Parser = ASN1Parser(bytes);
  var topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;
  //ASN1Object version = topLevelSeq.elements[0];
  //ASN1Object algorithm = topLevelSeq.elements[1];
  var privateKey = topLevelSeq.elements![2];

  asn1Parser = ASN1Parser(privateKey.valueBytes);
  var pkSeq = asn1Parser.nextObject() as ASN1Sequence;

  var modulus = pkSeq.elements![1] as ASN1Integer;
  //ASN1Integer publicExponent = pkSeq.elements[2] as ASN1Integer;
  var privateExponent = pkSeq.elements![3] as ASN1Integer;
  var p = pkSeq.elements![4] as ASN1Integer;
  var q = pkSeq.elements![5] as ASN1Integer;
  //ASN1Integer exp1 = pkSeq.elements[6] as ASN1Integer;
  //ASN1Integer exp2 = pkSeq.elements[7] as ASN1Integer;
  //ASN1Integer co = pkSeq.elements[8] as ASN1Integer;

  var rsaPrivateKey = RSAPrivateKey(
      modulus.integer!, privateExponent.integer!, p.integer, q.integer);

  return rsaPrivateKey;
}

Uint8List _getBytesFromPEMString(String pem, {bool checkHeader = true}) {
  var lines = LineSplitter.split(pem)
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  var base64;
  if (checkHeader) {
    if (lines.length < 2 ||
        !lines.first.startsWith('-----BEGIN') ||
        !lines.last.startsWith('-----END')) {
      throw ArgumentError('The given string does not have the correct '
          'begin/end markers expected in a PEM file.');
    }
    base64 = lines.sublist(1, lines.length - 1).join('');
  } else {
    base64 = lines.join('');
  }

  return Uint8List.fromList(base64Decode(base64));
}
