#include <iostream>
#include "gprotoc/msg.pb.h"

// EAST_TCP::MsgContent msg;

int main()
{
    EAST_TCP::MsgContent msg;
    msg.set_cmd(EAST_TCP::CMD_TYPE::RESPONSE);
    std::cout << "Hello world: = " << msg.cmd() << std::endl;
    return 0;
}

