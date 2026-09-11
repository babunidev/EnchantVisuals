#pragma once
#include <stdint.h>

namespace OctoEnchant {
constexpr uint32_t Marker = 0x40000000;
inline uint32_t ShamanCode(uint32_t visual) {
    switch (visual) {
    case 61: return 1; // Rockbiter
    case 32: return 2; // Flametongue
    case 81: return 3; // Windfury
    case 33: return 4; // Frostbrand
    default: return 0;
    }
}
inline uint32_t ShamanVisual(uint32_t code) {
    constexpr uint32_t values[] = {0, 61, 32, 81, 33};
    return code <= 4 ? values[code] : 0;
}
// These IDs exist only between the selection and rendering functions. Never
// write them to item fields, DBC records, or packets.
inline int Combine(int selected, uint32_t permanent, uint32_t temporary) {
    uint32_t code = ShamanCode(temporary);
    if (selected <= 0 || permanent == 0 || permanent > 0xffff ||
        static_cast<uint32_t>(selected) != permanent || !code || permanent == temporary)
        return selected;
    return static_cast<int>(Marker | (permanent << 8) | code);
}
inline bool Decode(int value, uint32_t& permanent, uint32_t& temporary) {
    uint32_t bits = static_cast<uint32_t>(value);
    if ((bits & 0xff000000) != Marker) return false;
    permanent = (bits >> 8) & 0xffff;
    temporary = ShamanVisual(bits & 0xff);
    return permanent != 0 && temporary != 0;
}
}
