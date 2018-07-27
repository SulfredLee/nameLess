#ifndef JWTSIGNER_H
#define JWTSIGNER_H
#include <string>

#include <openssl/opensslv.h>
#include <openssl/err.h>
#include <openssl/pem.h>
#include <openssl/hmac.h>
#include <openssl/evp.h>
#include <openssl/ossl_typ.h>

class EVP_MD_CTX_RAII
{
 public:
    EVP_MD_CTX_RAII();
    ~EVP_MD_CTX_RAII();

    EVP_MD_CTX* get();
 private:
    EVP_MD_CTX* m_ctx;
};

class JWTSigner
{
 public:
    std::string DoRS256Signe(const std::string& header, const std::string& payload, const std::string& privateKeyFile);
 private:
    std::string fileToString(const std::string& fileName);
    std::string RS256Digest(const std::string& privateKeyFile, const std::string& signed_area);
    EVP_PKEY* LoadKey(const char *key, bool public_key);
};

#endif
