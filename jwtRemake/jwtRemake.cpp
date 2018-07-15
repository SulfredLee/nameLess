#include "jwtRemake.h"
#include "base64Conver.h"

#include <string>
#include <sstream>
#include <vector>
#include <fstream>

EVP_MD_CTX_RAII::EVP_MD_CTX_RAII()
{
    m_ctx = EVP_MD_CTX_new();
}

EVP_MD_CTX_RAII::~EVP_MD_CTX_RAII()
{
    EVP_MD_CTX_free(m_ctx);
}

EVP_MD_CTX* EVP_MD_CTX_RAII::get()
{
    return m_ctx;
}

std::string JWT::DoRS256Signe(const std::string& header, const std::string& payload, const std::string& privateKeyFile)
{
    std::string header_enc = base64URLConvert::encode(header);
    std::string payload_enc = base64URLConvert::encode(payload);
    std::string signed_area = header_enc + '.' + payload_enc;
    std::string digest = RS256Digest(privateKeyFile, signed_area);
    if (digest == "")
    {
        return "";
    }
    else
    {
        return (signed_area + '.' + base64URLConvert::encode(digest));
    }
}

std::string JWT::fileToString(const std::string& fileName)
{
    std::ifstream FH(fileName);
    std::stringstream buffer;
    buffer << FH.rdbuf();
    return buffer.str();
}

std::string JWT::RS256Digest(const std::string& privateKeyFile, const std::string& signed_area)
{
    std::string result;

    EVP_PKEY* private_key = LoadKey(fileToString(privateKeyFile.c_str()).c_str(), false);
    // first sign
    EVP_MD_CTX_RAII ctxRAII;
    EVP_MD_CTX* ctx = ctxRAII.get();
    EVP_MD_CTX_init(ctx);
    EVP_DigestSignInit(ctx, NULL, (EVP_MD *)EVP_sha256(), NULL, private_key);

    const uint8_t* pSigned_area = reinterpret_cast<const uint8_t *>(signed_area.c_str());
    size_t needed = 0;
    if (EVP_DigestSignUpdate(ctx, pSigned_area, signed_area.size()) != 1)
    {
        return result;
    }
    // Figure out how many bytes we need
    if (EVP_DigestSignFinal(ctx, NULL, &needed) != 1)
    {
        return result;
    }
    std::vector<uint8_t> signature(needed);
    size_t signature_size = needed;
    if (EVP_DigestSignFinal(ctx, &(signature[0]), &signature_size) != 1)
    {
        return result;
    }
    result = std::string(reinterpret_cast<char *>(&signature[0]), signature_size);
    return result;
}

EVP_PKEY* JWT::LoadKey(const char *key, bool public_key)
{
    EVP_PKEY *evp_pkey = NULL;
    BIO *keybio = !key || !*key ? NULL : BIO_new_mem_buf(const_cast<void *>(reinterpret_cast<const void *>(key)), -1);
    if (keybio == NULL)
    {
        return NULL;
    }

    if (public_key)
    {
        evp_pkey = PEM_read_bio_PUBKEY(keybio, &evp_pkey, NULL, NULL);
    }
    else
    {
        evp_pkey = PEM_read_bio_PrivateKey(keybio, &evp_pkey, NULL, NULL);
    }

    BIO_free(keybio);

    if (evp_pkey == NULL)
    {
        char buffer[120];
        ERR_error_string(ERR_get_error(), buffer);
        fprintf(stderr, "Unable to construct %s due to: %s", public_key ? "public key" : "private key", buffer);
    }

    return evp_pkey;
}
