//
//  BaiduTrustPolicyManager.swift
//  Aria2D
//
//  Created by xjbeta on 2018/9/24.
//  Copyright © 2018 xjbeta. All rights reserved.
//

import Cocoa
import Alamofire

class BaiduTrustPolicyManager: ServerTrustPolicyManager {
    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        if host == "pan.baidu.com" || host == "wappass.baidu.com" {
            let baiducomCertificate = "MIIJVTCCCD2gAwIBAgIMcUHqUdLfXmQa+Pb2MA0GCSqGSIb3DQEBCwUAMGYxCzAJBgNVBAYTAkJFMRkwFwYDVQQKExBHbG9iYWxTaWduIG52LXNhMTwwOgYDVQQDEzNHbG9iYWxTaWduIE9yZ2FuaXphdGlvbiBWYWxpZGF0aW9uIENBIC0gU0hBMjU2IC0gRzIwHhcNMTgwODI4MDcyMjAyWhcNMTkwNTI2MDUzMTAyWjCBpzELMAkGA1UEBhMCQ04xEDAOBgNVBAgTB2JlaWppbmcxEDAOBgNVBAcTB2JlaWppbmcxJTAjBgNVBAsTHHNlcnZpY2Ugb3BlcmF0aW9uIGRlcGFydG1lbnQxOTA3BgNVBAoTMEJlaWppbmcgQmFpZHUgTmV0Y29tIFNjaWVuY2UgVGVjaG5vbG9neSBDby4sIEx0ZDESMBAGA1UEAxMJYmFpZHUuY29tMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAr6TDKhmBjiKc5USSOTCKxoz7yh+6TbA5MwWfKz7ZIMFjMJmSbqEsfyjIHtXnkz3x/GLGszJnXI2Ylk73VGzW64Nks7svAo+p01icllfjHHc69A0Z2EZKU3LI5/DzcdKI/vdzkSi6PXgbHsV2Y8aIIbcXbD5YA0DyhpWA5yBrmneSr2E2Xo+s88KFcg0yieS6opsqxdKMSpS6ixbFEQLr2XgyGmb2tbslOD6UuxGNRhRgXhx0kcGLJzhLh4IDFZemxYZ8fScewYkrFGZm6WzNdQZAWkw/QjkdS7EWCN+DBqToDaEBLtQkhiCiLLHLwsK69gfFfQvf4f79dJK3fo+lswIDAQABo4IFvzCCBbswDgYDVR0PAQH/BAQDAgWgMIGgBggrBgEFBQcBAQSBkzCBkDBNBggrBgEFBQcwAoZBaHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9jYWNlcnQvZ3Nvcmdhbml6YXRpb252YWxzaGEyZzJyMS5jcnQwPwYIKwYBBQUHMAGGM2h0dHA6Ly9vY3NwMi5nbG9iYWxzaWduLmNvbS9nc29yZ2FuaXphdGlvbnZhbHNoYTJnMjBWBgNVHSAETzBNMEEGCSsGAQQBoDIBFDA0MDIGCCsGAQUFBwIBFiZodHRwczovL3d3dy5nbG9iYWxzaWduLmNvbS9yZXBvc2l0b3J5LzAIBgZngQwBAgIwCQYDVR0TBAIwADCCAzsGA1UdEQSCAzIwggMuggliYWlkdS5jb22CEmNsaWNrLmhtLmJhaWR1LmNvbYIQY20ucG9zLmJhaWR1LmNvbYIQbG9nLmhtLmJhaWR1LmNvbYIUdXBkYXRlLnBhbi5iYWlkdS5jb22CEHduLnBvcy5iYWlkdS5jb22CCCouOTEuY29tggsqLmFpcGFnZS5jboIMKi5haXBhZ2UuY29tgg0qLmFwb2xsby5hdXRvggsqLmJhaWR1LmNvbYIOKi5iYWlkdWJjZS5jb22CEiouYmFpZHVjb250ZW50LmNvbYIOKi5iYWlkdXBjcy5jb22CESouYmFpZHVzdGF0aWMuY29tggwqLmJhaWZhZS5jb22CDiouYmFpZnViYW8uY29tgg8qLmJjZS5iYWlkdS5jb22CDSouYmNlaG9zdC5jb22CCyouYmRpbWcuY29tgg4qLmJkc3RhdGljLmNvbYINKi5iZHRqcmN2LmNvbYIRKi5iai5iYWlkdWJjZS5jb22CDSouY2h1YW5rZS5jb22CCyouZGxuZWwuY29tggsqLmRsbmVsLm9yZ4ISKi5kdWVyb3MuYmFpZHUuY29tghAqLmV5dW4uYmFpZHUuY29tghEqLmZhbnlpLmJhaWR1LmNvbYIRKi5nei5iYWlkdWJjZS5jb22CEiouaGFvMTIzLmJhaWR1LmNvbYIMKi5oYW8xMjMuY29tgg4qLmltLmJhaWR1LmNvbYIPKi5tYXAuYmFpZHUuY29tgg8qLm1iZC5iYWlkdS5jb22CDCoubWlwY2RuLmNvbYIQKi5uZXdzLmJhaWR1LmNvbYILKi5udW9taS5jb22CECouc2FmZS5iYWlkdS5jb22CDiouc21hcnRhcHBzLmNughEqLnNzbDIuZHVhcHBzLmNvbYIOKi5zdS5iYWlkdS5jb22CDSoudHJ1c3Rnby5jb22CEioueHVlc2h1LmJhaWR1LmNvbYILYXBvbGxvLmF1dG+CCmJhaWZhZS5jb22CDGJhaWZ1YmFvLmNvbYIGZHd6LmNugg9tY3QueS5udW9taS5jb22CDHd3dy5iYWlkdS5jboIQd3d3LmJhaWR1LmNvbS5jbjAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwHQYDVR0OBBYEFEU2rOodiWjhKzkRrSOc0Vk2i7DMMB8GA1UdIwQYMBaAFJbeYfG9HBYpUxzAzH07gwBA5hp8MIIBAwYKKwYBBAHWeQIEAgSB9ASB8QDvAHYAh3W/51l8+IxDmV+9827/Vo1HVjb/SrVgwbTq/16ggw8AAAFlf2kuyQAABAMARzBFAiBOBciIArwqG/cPXCluJTmnClQ9ZjNt3j4qvzOYyA77kAIhAIlzlKA0Oue+j8qkC90HJ+4n8MTUxmxi3eWcANqkoTN8AHUApLkJkLQYWBSHuxOizGdwCjw1mAT5G9+443fNDsgN3BAAAAFlf2kvMwAABAMARjBEAiAdxlJEXbZbvtD+5ZavxYvja0yEBhT0GHiZUysP83oOWQIgbpCAqugzzsrXDo0K0tNAczhWa7+FqQPTwHB6mWgFxEEwDQYJKoZIhvcNAQELBQADggEBAAT9qh7NQ30CgJqSMOUKHMA3gQG58dUOz3bedK2+USSfHn9m5n75p6644Ln2Yt4ITLGbznT7YjLp+YfYBB1aM0EShkf5ztL3nYOUB8qSyM4QeKQ9Ou2l00BDA9wMj/Mh9eHy7ZIOETt6jNAG/PGoEsoGn4q+bDV5l2XIyRocwlqfbE/0vZcORXN8XRuGkMb2+dOu36iNXTtD6qQdxlCtpSfM1jgLCBLHs8wgj0vuc1TSY/c2D7FFaL33fxkjqLZd9vLcZ66p4lv1HeLJCFmpIzBrEnSUsTa9pGqsl1suET0/8ITgZBD7VZBXleFV7GJTH0WCFKu0B7x3ko0cUktFHTU="
            
            
            
            guard let certificateData = Data(base64Encoded: baiducomCertificate) as CFData?,
                let certificate = SecCertificateCreateWithData(nil, certificateData) else {
                    assert(false, "init certificate false")
            }
            
            func extractPublicKeysFromCertificates(_ certs: [SecCertificate]) -> [SecKey] {
                var publicKeys: [SecKey] = []
                var trust: SecTrust?
                let policy = SecPolicyCreateBasicX509()
                for cert in certs {
                    let status = SecTrustCreateWithCertificates(cert, policy, &trust)
                    var key: SecKey?
                    if status == errSecSuccess {
                        guard let finalTrust = trust else { return [] }
                        key = SecTrustCopyPublicKey(finalTrust)
                    }
                    guard let publicKey = key else { return [] }
                    publicKeys.append(publicKey)
                }
                
                return publicKeys
            }
            
            let publicKeys = extractPublicKeysFromCertificates([certificate])

            let trustPolicy = ServerTrustPolicy.pinPublicKeys(publicKeys: publicKeys, validateCertificateChain: true, validateHost: true)
            
//            let trustPolicy = ServerTrustPolicy.pinCertificates(certificates: [certificate], validateCertificateChain: true, validateHost: true)
            return trustPolicy
        } else {
            return .disableEvaluation
        }
    }
}
