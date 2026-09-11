#pragma once
#include <stdint.h>
#include <stddef.h>
struct ClientSignature { uintptr_t address; size_t length; uint64_t hash; };
static constexpr ClientSignature clientSignatures[] = {
    {0x5D9B70, 0x8E, 0x5303EAF87E624FC4ull},
    {0x62EC70, 0x84, 0xD29FD48DA831DC3Bull},
    {0x479700, 0xAE, 0xC0457AE1C1290937ull},
    {0x712F70, 0xA8, 0x55C8B95A37E020DAull},
    {0x713070, 0x21, 0x9FF5E26936FFE260ull},
};
