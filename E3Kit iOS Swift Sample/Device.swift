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

    init(withIdentity identity: String) {
        self.identity = identity
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
        EThree.initialize(tokenCallback: tokenCallback) { eThree, error in
            self.eThree = eThree
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
            if error as? EThreeError == .userIsAlreadyRegistered {
                eThree.rotatePrivateKey { error in
                    completion?(error)
                }

                return
            }

            completion?(error)
        }
        //# end of snippet: e3kit_register
    }

    func lookupPublicKeys(of identities: [String], completion: ResultCompletion<EThree.LookupResult>?) {
        guard let eThree = eThree else {
            completion?(.failure(AppError.eThreeNotInitialized))
            return
        }

        //# start of snippet: e3kit_lookup_public_keys
        eThree.lookupPublicKeys(of: identities) { result, error in
            if let result = result {
                completion?(.success(result))
            } else if let error = error {
                completion?(.failure(error))
            }
        }
        //# end of snippet: e3kit_lookup_public_keys
    }

    func encrypt(text: String, for lookupResult: EThree.LookupResult? = nil) throws -> String {
        guard let eThree = eThree else {
            throw AppError.eThreeNotInitialized
        }

        //# start of snippet: e3kit_encrypt
        let encryptedText = try eThree.encrypt(text: text, for: lookupResult)
        //# end of snippet: e3kit_encrypt

        return encryptedText
    }

    func decrypt(text: String, from senderPublicKey: VirgilPublicKey? = nil) throws -> String {
        guard let eThree = eThree else {
            throw AppError.eThreeNotInitialized
        }

        //# start of snippet: e3kit_decrypt
        let decryptedText = try eThree.decrypt(text: text, from: senderPublicKey)
        //# end of snippet: e3kit_decrypt

        return decryptedText
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
}
