# Virgil Security Objective-C/Swift Crypto Library Wrapper

[![Build Status](https://api.travis-ci.com/VirgilSecurity/virgil-cryptowrapper-x.svg?branch=master)](https://travis-ci.com/VirgilSecurity/virgil-cryptowrapper-x)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/VirgilCryptoFoundation.svg)](https://cocoapods.org/pods/VirgilCryptoFoundation)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![Platform](https://img.shields.io/cocoapods/p/VirgilCryptoFoundation.svg?style=flat)
[![GitHub license](https://img.shields.io/badge/license-BSD%203--Clause-blue.svg)](https://github.com/VirgilSecurity/virgil/blob/master/LICENSE)

### [Introduction](#introduction) | [Features](#features) | [Installation](#installation) | [Docs](#docs) | [License](#license) | [Contacts](#support)

## Introduction
This library is designed to be a small, flexible and convenient wrapper for a variety of crypto algorithms. So it can be used in a small microcontroller as well as in a high load server application. Also, it provides a bunch of custom hybrid algorithms that combine different crypto algorithms to solve common complex cryptographic problems in an easy way. That eliminates requirement for developers to have a strong cryptographic skills.

Virgil Security Objective-C/Swift Crypto Library Wrapper is a wrapper for [Virgil Security Crypto Library](https://github.com/VirgilSecurity/virgil-crypto-c).

## Features
Virgil Security Crypto library wrapper is decomposed to small libraries with specific purposes, so a developer can freely choose a subset of them.

### Library: Foundation

This library contains basic cryptographic algorithms and can be used as building blocks for complex solutions.

| Algorithm Purpose           | Implementation details                                                                                                                                    |
|-----------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------|
| Key Generation, PRNG        | CTR_DRBG [NIST SP 800-90A](http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-90Ar1.pdf)                                                    |
| Key Derivation              | [KDF1, KDF2](https://www.shoup.net/iso/std6.pdf),  [HKDF](https://tools.ietf.org/html/rfc5869), [PBKDF2](https://tools.ietf.org/html/rfc8018#section-5.2) |
| Key Exchange                | [X25519](https://tools.ietf.org/html/rfc7748), [RSA](http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-56Br1.pdf)                          |
| Hashing                     | [SHA-2 (224/256/384/512)](https://tools.ietf.org/html/rfc4634)                                                                                            |
| Message Authentication Code | [HMAC](https://www.ietf.org/rfc/rfc2104.txt)                                                                                                              |
| Digital Signature           | [Ed25519](https://tools.ietf.org/html/rfc8032), [RSASSA-PSS](https://tools.ietf.org/html/rfc4056)                                                         |
| Entropy Source              | Linux, macOS [/dev/urandom](https://tls.mbed.org/module-level-design-rng),<br>Windows [CryptGenRandom()](https://tls.mbed.org/module-level-design-rng)    |
| Symmetric Algorithms        | [AES-256-GCM](http://nvlpubs.nist.gov/nistpubs/Legacy/SP/nistspecialpublication800-38d.pdf), [AES-256-CBC](https://tools.ietf.org/html/rfc3602)           |
| Encryption schemes          | [PBES2](https://tools.ietf.org/html/rfc8018#section-6.2)                                                                                                  |
| Elliptic Curves             | [Ed25519](https://tools.ietf.org/html/rfc8032), [Curve25519](https://tools.ietf.org/html/rfc7748)                                                         |

### Library: Pythia

Cryptographic background for the [Password-Hardened Encryption (PHE) protocol](https://virgilsecurity.com/wp-content/uploads/2018/11/PHE-Whitepaper-2018.pdf) that provides developers with a technology to protect users passwords from offline attacks and make stolen passwords useless even if your database has been compromised. Service implementation can be found [here](https://github.com/passw0rd/phe-go).

### Library: Ratchet

Implementation of the [Double Ratchet](https://signal.org/docs/specifications/doubleratchet/) protocol.

## Installation

VirgilCrypto is provided as a set of frameworks. These frameworks are distributed via Carthage and CocoaPods.

All frameworks are available for:
- iOS 9.0+
- macOS 10.9+
- tvOS 9.0+
- watchOS 2.0+

### COCOAPODS

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate VirgilCryptoWrapper into your Xcode project using CocoaPods, specify it in your *Podfile*:

```bash
target '<Your Target Name>' do
  use_frameworks!

  pod 'VirgilCryptoFoundation', '~> 0.6.0'
  pod 'VirgilCryptoRatchet', '~> 0.6.0'
  pod 'VirgilCryptoPythia', '~> 0.6.0'
end
```

__NOTE__: It's not mandatory to include all this dependencies, add only frameworks you are going to use.

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate VirgilCryptoWrapper into your Xcode project using Carthage, create an empty file with name *Cartfile* in your project's root folder and add following lines to your *Cartfile*

```
github "VirgilSecurity/virgil-cryptowrapper-x" ~> 0.6.0
```

#### Linking against prebuilt binaries

To link prebuilt frameworks to your app, run following command:

```bash
$ carthage update
```

This will build each dependency or download a pre-compiled framework from github Releases.

##### Building for iOS/tvOS/watchOS

On your application target's “General” settings tab, in the “Linked Frameworks and Libraries” section, add following frameworks from the *Carthage/Build* folder inside your project's folder:
 - VirgilCryptoFoundation
 - VirgilCryptoRatchet
 - VirgilCryptoPythia
 - VSCCommon
 - VSCFoundation
 - VSCRatchet
 - VSCPythia
 
 __NOTE__: It's not mandatory to include all this dependencies, add only frameworks you are going to use. Frameworks with VSC prefix in their name are written in C, those without prefix are swift frameworks. It is mandatory to include VSCCommon and for any VirgilCryptoNAME.framework add also VSCNAME.framework. 

On your application target's “Build Phases” settings tab, click the “+” icon and choose “New Run Script Phase”. Create a Run Script in which you specify your shell (ex: */bin/sh*), add the following contents to the script area below the shell:

```bash
/usr/local/bin/carthage copy-frameworks
```

and add the paths to the frameworks you want to use under “Input Files”, e.g.:

```
$(SRCROOT)/Carthage/Build/iOS/VirgilCryptoFoundation.framework
$(SRCROOT)/Carthage/Build/iOS/VirgilCryptoRatchet.framework
$(SRCROOT)/Carthage/Build/iOS/VirgilCryptoPythia.framework
$(SRCROOT)/Carthage/Build/iOS/VSCCommon.framework
$(SRCROOT)/Carthage/Build/iOS/VSCFoundation.framework
$(SRCROOT)/Carthage/Build/iOS/VSCRatchet.framework
$(SRCROOT)/Carthage/Build/iOS/VSCPythia.framework
```

##### Building for macOS

On your application target's “General” settings tab, in the “Embedded Binaries” section, drag and drop following frameworks from the Carthage/Build folder on disk:
- VirgilCryptoFoundation
- VirgilCryptoRatchet
- VirgilCryptoPythia
- VSCCommon
- VSCFoundation
- VSCRatchet
- VSCPythia

Additionally, you'll need to copy debug symbols for debugging and crash reporting on macOS.

On your application target’s “Build Phases” settings tab, click the “+” icon and choose “New Copy Files Phase”.
Click the “Destination” drop-down menu and select “Products Directory”. For each framework, drag and drop the corresponding dSYM file.

## Docs
- [Crypto Core Library](https://github.com/VirgilSecurity/virgil-crypto-c)
- [More usage examples](https://developer.virgilsecurity.com/docs/how-to#cryptography)

## License

This library is released under the [3-clause BSD License](LICENSE).

## Support
Our developer support team is here to help you.

You can find us on [Twitter](https://twitter.com/VirgilSecurity) or send us email support@VirgilSecurity.com.

Also, get extra help from our support team on [Slack](https://virgilsecurity.com/join-community).
