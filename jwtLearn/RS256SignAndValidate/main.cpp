#include <iostream>
#include <string>
#include <sstream>

#include "jwt/jwt_all.h"
#include "jwt/messagevalidator.h"
using json = nlohmann::json;

int main(int argc, char* argv[])
{
    std::string publicKey = "/home/sulfred/Documents/SoftwareDev/github/Sulfred/nameLess/build/public_key.pem";
    std::string privateKey = "/home/sulfred/Documents/SoftwareDev/github/Sulfred/nameLess/build/private_key.pem";
    std::stringstream json_signer;
    json_signer << "{";
    json_signer << "\"RS256\":{";
    json_signer << "\"public\":{\"fromfile\":\"" << publicKey << "\"},";
    json_signer << "\"private\":{\"fromfile\":\"" << privateKey << "\"}";
    json_signer << "}";
    json_signer << "}";
    signer_ptr signer(MessageValidatorFactory::BuildSigner(json_signer.str()));

    json payload = {
        {"sub", "1234567890"},
        {"name", "John"},
        {"admin", true},
        {"jti", "52748d98-3435-4b02-8ed1-d1cbf0974172"},
        {"iat", 1531446766},
        {"exp", 1531450366}};
    json header = {
        {"typ", "JWT"},
        {"alg", "RS256"}
    };

    // Let's encode the token to a string
    std::string token = JWT::Encode(*(signer.get()), payload, header);
    std::cout << token << std::endl;

    try
    {
        std::stringstream json_validators;
        json_validators << "{\"set\":[";
        json_validators << "{\"RS256\":{\"public\":{\"fromfile\":\"" << publicKey << "\"}}}";
        json_validators << "]}";
        validator_ptr message_validator(MessageValidatorFactory::Build(json_validators.str()));

        json header, payload;
        std::tie(header, payload) = JWT::Decode(token, message_validator.get());
        std::cout << "Header: " << header << std::endl;
        std::cout << "Payload: " << payload << std::endl;
    }
    catch (InvalidTokenError &tfe)
    {
        std::cout << tfe.what() << std::endl;
    }
    return 0;
}
