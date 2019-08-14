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

var log: (_ text: Any) -> Void = { print($0) }

class ViewController: UIViewController {
    @IBOutlet weak var logsTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        log = { [weak self] text in
            DispatchQueue.main.async {
                print(text)
                self?.logsTextView.text += "\(text)\n"
            }
        }

        log("* Testing main methods:");
        log("\n----- EThree.initialize -----");
        initializeUsers {
            log("\n----- EThree.register -----");
            self.registerUsers {
                log("\n----- EThree.lookupPublicKeys -----");
                self.lookupPublicKeys {
                    do {
                        log("\n----- EThree.encrypt & EThree.decrypt -----");
                        try self.encryptAndDecrypt()
                    } catch(let e) {
                        log(e)
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
        alice.initialize { error in
            if let error = error {
                log("Failed initializing \(self.alice.identity): \(error)")
                return
            } else {
                log("Initialized \(self.alice.identity)")
            }

            self.bob.initialize { error in
                if let error = error {
                    log("Failed initializing \(self.bob.identity): \(error)")
                    return
                } else {
                    log("Initialized \(self.bob.identity)")
                }

                completion()
            }
        }
    }

    func registerUsers(_ completion: @escaping Completion) {
        alice.register { error in
            if let error = error {
                log("Failed registering \(self.alice.identity): \(error)")
                return
            } else {
                log("Registered \(self.alice.identity)")
            }

            self.bob.register { error in
                if let error = error {
                    log("Failed registering \(self.bob.identity): \(error)")
                    return
                } else {
                    log("Registered \(self.bob.identity)")
                }

                completion()
            }
        }
    }


    func lookupPublicKeys(_ completion: @escaping Completion) {
        alice.lookupPublicKeys(of: [bob.identity]) {
            switch $0 {
            case .failure(let error):
                log("Failed looking up \(self.bob.identity)'s public key: \(error)")
            case .success(let lookup):
                log("Looked up \(self.bob.identity)'s public key")
                self.bobLookup = lookup
            }

            self.bob.lookupPublicKeys(of: [self.alice.identity]) {
                switch $0 {
                case .failure(let error):
                    log("Failed looking up \(self.alice.identity)'s public key: \(error)")
                case .success(let lookup):
                    log("Looked up \(self.alice.identity)'s public key")
                    self.aliceLookup = lookup
                    completion()
                }
            }
        }
    }

    func encryptAndDecrypt() throws {
        var time0 = timeInMs()
        let aliceEncryptedText = try alice.encrypt(text: "Hello \(bob.identity)!", for: bobLookup)
        var time1 = timeInMs()

        log("\(alice.identity) encrypts and signs: '\(aliceEncryptedText)'. Took: \(time1 - time0)ms")

        time0 = timeInMs()
        let aliceDecryptedText = try bob.decrypt(text: aliceEncryptedText, from: aliceLookup![alice.identity])
        time1 = timeInMs()

        log("\(bob.identity) decrypts and verifies \(alice.identity)'s signature: '\(aliceDecryptedText)'. Took: \(time1 - time0)ms")

        time0 = timeInMs()
        let bobEncryptedText = try bob.encrypt(text: "Hello \(alice.identity)!", for: aliceLookup)
        time1 = timeInMs()

        log("\(bob.identity) encrypts and signs: '\(bobEncryptedText)'. Took: \(time1 - time0)ms")

        time0 = timeInMs()
        let bobDecryptedText = try alice.decrypt(text: bobEncryptedText, from: bobLookup![bob.identity])
        time1 = timeInMs()

        log("\(alice.identity) decrypts and verifies \(bob.identity)'s signature: '\(bobDecryptedText)'. Took: \(time1 - time0)ms")
    }

    func timeInMs() -> Double {
        return Double(DispatchTime.now().rawValue)/1000000
    }

}

