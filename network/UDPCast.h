#ifndef UDPCAST_H
#define UDPCAST_H
#include <string>
#include <vector>

class UDPCast
{
 public:
    enum class UDPStatus {SUCCESS, ERROR, READ};
 public:
    UDPCast();
    virtual ~UDPCast();

    UDPStatus InitComponent(const std::string& ifAddress, const short ifPort, bool isClient);
    // Set time to live
    UDPStatus SetTTL(int ttl);

    // Client, Server
    UDPStatus Send(std::string& toAddress, short& toPort, const std::vector<char>& sendMsg, const int msgLength);
    UDPStatus Recv(std::string& fromAddress, short& fromPort, std::vector<char>& receiveBuffer, int& byteRecv);
 private:
    int m_socket;
    std::string m_ifAddress;
    short m_ifPort;
    bool m_isClient;
 private:
    UDPStatus Start();
    void Stop();
 private:
};
#endif
