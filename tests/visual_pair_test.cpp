#include "VisualPair.h"
#include <assert.h>
#include <stdio.h>
#include <initializer_list>
int main() {
    using namespace EnchantVisuals;
    uint32_t p = 0, t = 0;
    for (uint32_t visual : {61u, 32u, 81u, 33u}) {
        int combined = Combine(2, 2, visual);
        assert(combined > 0 && Decode(combined, p, t) && p == 2 && t == visual);
    }
    assert(Combine(2, 2, 0) == 2);       // Expired or removed imbue.
    assert(Combine(81, 0, 81) == 81);   // No permanent enchant.
    assert(Combine(2, 2, 26) == 2);     // Poison is outside scope.
    assert(Combine(-1, 2, 81) == -1);   // Preserve built-in weapon visual.
    assert(Combine(0, 2, 81) == 0);
    assert(Combine(24, 2, 81) == 24);   // Preserve other selection priorities.
    assert(Combine(81, 81, 81) == 81);  // Avoid a duplicate effect.
    assert(Combine(2, 65536, 81) == 2);
    assert(!Decode(2, p, t));
    assert(!Decode(-1, p, t));
    assert(!Decode(0x40000205, p, t));
    // Different active combinations must invalidate a caller's visual cache.
    assert(Combine(2, 2, 81) != Combine(2, 2, 32));
    assert(Combine(2, 2, 81) != Combine(24, 24, 81));
    puts("Visual selection tests passed.");
}
