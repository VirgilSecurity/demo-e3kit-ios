//
//  Device.swift
//  E3Kit iOS Swift Sample
//
//  Created by Matheus Cardoso on 4/18/19.
//  Developer Relations Engineer @ Virgil Security
//

//# start of snippet: e3kit_imports
import VirgilE3Kit
import VirgilSDK
import VirgilCrypto
//# end of snippet: e3kit_imports

typealias Completion = () -> Void
typealias FailableCompletion = (Error?) -> Void
typealias ResultCompletion<T> = (Swift.Result<T, Error>) -> Void

class Device: NSObject {
    let identity: String
    var eThree: EThree?
    var authToken: String?

    // setting this to true can cause a momentary hang in the app
    // because encryption and decryption will be ran 100x each.
    let benchmarking = false

    init(withIdentity identity: String) {
        self.identity = identity
    }

    func _log(_ text: Any) {
        log("[\(identity)] \(text)")
    }

    // First step in e3kit flow is to initialize the SDK (eThree instance)
    func initialize(_ completion: FailableCompletion? = nil) {
        let identity = self.identity

        //# start of snippet: e3kit_authenticate
        let authCallback = { () -> String? in
            let connection = HttpConnection()

            guard let url = URL(string: "http://localhost:3000/authenticate") else {
                return nil
            }

            let headers = ["Content-Type": "application/json"]
            let params = ["identity": identity]

            guard let requestBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
                return nil
            }

            let request = Request(url: url, method: .post, headers: headers, body: requestBody)

            guard
                let response = try? connection.send(request).startSync().get(),
                let body = response.body
            else {
                return nil
            }

            guard let json = try? JSONSerialization.jsonObject(with: body, options: []) as? [String: Any] else {
                return nil
            }

            return json["authToken"] as? String
        }

        authToken = authCallback()
        //# end of snippet: e3kit_authenticate

        //# start of snippet: e3kit_jwt_callback
        let tokenCallback: EThree.RenewJwtCallback = { completion in
            guard let url = URL(string: "http://localhost:3000/virgil-jwt") else {
                return completion(nil, AppError.invalidUrl)
            }

            guard let authToken = self.authToken else {
                return completion(nil, AppError.notAuthenticated)
            }

            let headers = [
                "Content-Type": "application/json",
                "Authorization": "Bearer " + authToken
            ]

            let request = Request(url: url, method: .get, headers: headers)

            let connection = HttpConnection()

            guard
                let response = try? connection.send(request).startSync().get(),
                let body = response.body,
                let json = try? JSONSerialization.jsonObject(with: body, options: []) as? [String: Any],
                let jwtString = json["virgilToken"] as? String
                else {
                    return completion(nil, AppError.gettingJwtFailed)
            }

            completion(jwtString, nil)
        }
        //# end of snippet: e3kit_jwt_callback

        //# start of snippet: e3kit_initialize
        do {
            eThree = try EThree(identity: identity, tokenCallback: tokenCallback)
            self._log("Initialized")
            completion?(nil)
        } catch let error {
            self._log("Failed initializing: \(error)")
            completion?(error)
        }
        //# end of snippet: e3kit_initialize
    }

    func register(_ completion: FailableCompletion? = nil) {
        guard let eThree = eThree else {
            completion?(AppError.eThreeNotInitialized)
            return
        }

        //# start of snippet: e3kit_has_local_private_key
        if (try? eThree.hasLocalPrivateKey()) == true {
            try? eThree.cleanUp()
        }
        //# end of snippet: e3kit_has_local_private_key

        //# start of snippet: e3kit_register
        eThree.register { error in
            if let error = error {
                self._log("Failed registering: \(error)")
            }

            if error as? EThreeError == .userIsAlreadyRegistered {
                eThree.rotatePrivateKey { error in
                    self._log("Rotated private key instead")
                    completion?(error)
                }

                return
            }

            self._log("Registered")

            completion?(error)
        }
        //# end of snippet: e3kit_register
    }

    func findUsers(with identities: [String], completion: ResultCompletion<FindUsersResult>?) {
        guard let eThree = eThree else {
            completion?(.failure(AppError.eThreeNotInitialized))
            return
        }

        //# start of snippet: e3kit_lookup_public_keys
        eThree.findUsers(with: identities) { result, error in
            if let result = result {
                self._log("Looked up \(identities)'s public key")
                completion?(.success(result))
            } else if let error = error {
                self._log("Failed looking up \(identities)'s public key: \(error)")
                completion?(.failure(error))
            }
        }
        //# end of snippet: e3kit_lookup_public_keys
    }

    func encrypt(text: String, for findUsersResult: FindUsersResult? = nil) throws -> String {
        guard let eThree = eThree else {
            throw AppError.eThreeNotInitialized
        }

        let then = timeInMs()

        do {
            let repetitions = benchmarking ? 100 : 1
            var encryptedText: String = ""
            for _ in (1...repetitions) {
                //# start of snippet: e3kit_auth_encrypt
                encryptedText = try eThree.authEncrypt(text: text, for: findUsersResult!)
                //# end of snippet: e3kit_auth_encrypt
            }
            let time = (timeInMs() - then)/Double(repetitions)
            self._log("Encrypted and signed: '\(encryptedText)'. Took: \(time)ms")
            return encryptedText
        } catch(let error) {
            self._log("Failed encrypting and signing: \(error)")
            throw error
        }
    }

    func decrypt(text: String, from user: Card? = nil) throws -> String {
        guard let eThree = eThree else {
            throw AppError.eThreeNotInitialized
        }

        let then = timeInMs()

        do {
            let repetitions = benchmarking ? 100 : 1
            var decryptedText: String = ""
            for _ in (1...repetitions) {
                //# start of snippet: e3kit_auth_decrypt
                decryptedText = try eThree.authDecrypt(text: text, from: user)
                //# end of snippet: e3kit_auth_decrypt
            }
            let time = (timeInMs() - then)/Double(repetitions)
            self._log("Decrypted and verified: '\(decryptedText)'. Took: \(time)ms")
            return decryptedText
        } catch(let error) {
            self._log("Failed decrypting and verifying: \(error)")
            throw error
        }
    }

    func hasLocalPrivateKey() throws -> Bool {
        guard let eThree = eThree else {
            throw AppError.eThreeNotInitialized
        }

        //# start of snippet: e3kit_has_local_private_key
        let hasLocalPrivateKey = try eThree.hasLocalPrivateKey()
        //# end of snippet: e3kit_has_local_private_key

        return hasLocalPrivateKey
    }

    func backupPrivateKey(password: String, completion: FailableCompletion? = nil) {
        guard let eThree = eThree else {
            completion?(AppError.eThreeNotInitialized)
            return
        }

        //# start of snippet: e3kit_backup_private_key
        eThree.backupPrivateKey(password: password) { error in
            completion?(error)
        }
        //# end of snippet: e3kit_backup_private_key
    }

    func restorePrivateKey(password: String, completion: FailableCompletion? = nil) {
        guard let eThree = eThree else {
            completion?(AppError.eThreeNotInitialized)
            return
        }

        //# start of snippet: e3kit_restore_private_key
        eThree.restorePrivateKey(password: password) { error in
            completion?(error)
        }
        //# end of snippet: e3kit_restore_private_key
    }

    func rotatePrivateKey(completion: FailableCompletion? = nil) {
        guard let eThree = eThree else {
            completion?(AppError.eThreeNotInitialized)
            return
        }

        //# start of snippet: e3kit_rotate_private_key
        eThree.rotatePrivateKey { error in
            completion?(error)
        }
        //# end of snippet: e3kit_rotate_private_key
    }

    func unregister(completion: FailableCompletion? = nil) {
        guard let eThree = eThree else {
            completion?(AppError.eThreeNotInitialized)
            return
        }

        //# start of snippet: e3kit_unregister
        eThree.unregister { error in
            completion?(error)
        }
        //# end of snippet: e3kit_unregister
    }
}
