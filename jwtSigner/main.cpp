#include <iostream>
#include <string>

#include "jwtSigner.h"
#include "base64URLConver.h"

int main(int argc, char* argv[])
{
    std::string privateKey = "/home/sulfred/Documents/SoftwareDev/github/SulfredLee/nameLess/build/private_key.pem";
    std::string payload = "{\"admin\":true,\"exp\":1531450366,\"iat\":1531446766,\"jti\":\"52748d98-3435-4b02-8ed1-d1cbf0974172\",\"name\":\"John\",\"sub\":\"1234567890\"}";
    std::string header = "{\"alg\":\"RS256\",\"typ\":\"JWT\"}";

    JWTSigner jwtEngine;
    std::cout << jwtEngine.DoRS256Signe(header, payload, privateKey) << std::endl;
    return 0;
}
