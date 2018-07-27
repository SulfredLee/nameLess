#ifndef BASE64URLCONVERT_H
#define BASE64URLCONVERT_h
#include <string>

class base64URLConvert
{
 public:
    static std::string encode(const std::string & in);
    static std::string decode(const std::string & in);
};

#endif
