//
//  ViewController.swift
//  E3Kit iOS Swift Sample
//
//  Created by Matheus Cardoso on 4/18/19.
//  Copyright © 2019 cardoso. All rights reserved.
//

import UIKit
import VirgilE3Kit
import VirgilCrypto

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeUsers {
            self.registerUsers {
                self.lookupPublicKeys {
                    do {
                        try self.encryptAndDecrypt()
                    } catch(let e) {
                        print(e)
                    }
                }
            }
        }
    }

    let alice = Device(withIdentity: "Alice")
    let bob = Device(withIdentity: "Bob")

    var bobLookup: EThree.LookupResult?
    var aliceLookup: EThree.LookupResult?

    func initializeUsers(_ completion: @escaping Completion) {
        print("Initializing Alice")
        alice.initialize { error in
            if let error = error {
                print("Failed initializing Alice: \(error)")
                return
            }

            print("Initializing Bob")
            self.bob.initialize { error in
                if let error = error {
                    print("Failed initializing Bob: \(error)")
                    return
                }

                completion()
            }
        }
    }

    func registerUsers(_ completion: @escaping Completion) {
        print("Registering Alice")
        alice.register { error in
            if let error = error {
                print("Failed registering Alice: \(error)")
                return
            }

            print("Registering Bob")
            self.bob.register { error in
                if let error = error {
                    print("Failed registering Bob: \(error)")
                    return
                }

                completion()
            }
        }
    }


    func lookupPublicKeys(_ completion: @escaping Completion) {
        print("Looking up Bob's public key")
        alice.lookupPublicKeys(of: ["Bob"]) {
            switch $0 {
            case .failure(let error):
                print("Failed looking up Bob's public key: \(error)")
            case .success(let lookup):
                self.bobLookup = lookup
            }

            print("Looking up Alice's public key")
            self.bob.lookupPublicKeys(of: ["Alice"]) {
                switch $0 {
                case .failure(let error):
                    print("Failed looking up Alice's public key: \(error)")
                case .success(let lookup):
                    self.aliceLookup = lookup
                    completion()
                }
            }
        }
    }

    func encryptAndDecrypt() throws {
        let aliceEncryptedText = try alice.encrypt(text: "Hello Bob!", for: bobLookup)
        print("Alice encrypts and signs: '\(aliceEncryptedText)'")
        let aliceDecryptedText = try bob.decrypt(text: aliceEncryptedText, from: aliceLookup!["Alice"])
        print("Bob decrypts and verifies Alice's signature: '\(aliceDecryptedText)'")

        let bobEncryptedText = try bob.encrypt(text: "Hello Alice!", for: aliceLookup)
        print("Bob encrypts and signs: '\(bobEncryptedText)'")
        let bobDecryptedText = try alice.decrypt(text: bobEncryptedText, from: bobLookup!["Bob"])
        print("Alice decrypts and verifies Bob's signature: '\(bobDecryptedText)'")
    }

}

