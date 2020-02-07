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
                    self.lookupPublicKeys {
                    let uuid = UUID().uuidString
                    self.alice.eThree?.createGroup(id: uuid, with: self.bobLookup).start { result in
                            switch result {
                            case .success(let group):
                                log("created group \(group)...")
                                log("bob will rotate key and load group...")
                                try? self.bob.eThree?.cleanUp()
                                self.bob.eThree?.rotatePrivateKey { error in
                                    if let error = error {
                                        log("failed rotating: \(error)")
                                    }
                                    
                                    self.bob.eThree?.loadGroup(id: uuid, initiator: self.aliceLookup![self.alice.identity]!).start { result in
                                        switch result {
                                        case .success(let group):
                                            log("bob loaded group: \(group)")
                                        case .failure(let error):
                                            log("bob failed loading group: \(error)")
                                        }

                                    }
                                }
                            case .failure(let error):
                                log("failed creating group: \(error)")
                                break
                            }
                        }
                    }
            }
        }
    }

    let alice = Device(withIdentity: "Alice")
    let bob = Device(withIdentity: "Bob")

    var bobLookup: FindUsersResult?
    var aliceLookup: FindUsersResult?

    func initializeUsers(_ completion: @escaping Completion) {
        alice.initialize { _ in
            self.bob.initialize { _ in
                completion()
            }
        }
    }

    func registerUsers(_ completion: @escaping Completion) {
        alice.register { _ in
            self.bob.register { _ in
                completion()
            }
        }
    }

    func lookupPublicKeys(_ completion: @escaping Completion) {
        alice.findUsers(with: [bob.identity]) {
            switch $0 {
            case .failure:
                break
            case .success(let lookup):
                self.bobLookup = lookup
            }

            self.bob.findUsers(with: [self.alice.identity]) {
                switch $0 {
                case .failure:
                    break
                case .success(let lookup):
                    self.aliceLookup = lookup
                    completion()
                }
            }
        }
    }

    func encryptAndDecrypt() throws {
        let aliceEncryptedText = try alice.encrypt(text: "Hello \(bob.identity)! How are you?", for: bobLookup)
        _ = try bob.decrypt(text: aliceEncryptedText, from: aliceLookup?[alice.identity])
        let bobEncryptedText = try bob.encrypt(text: "Hello \(alice.identity)! How are you?", for: aliceLookup)
        _ = try alice.decrypt(text: bobEncryptedText, from: bobLookup?[bob.identity])
    }
}

