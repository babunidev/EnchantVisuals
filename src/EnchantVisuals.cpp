// Experimental cosmetic extension for the locally inspected 1.12.1 client.
// See README.md for provenance, scope, and the required in-game checks.
#include <windows.h>
#include <stdio.h>
#include <string.h>
#include "MinHook.h"
#include "VisualPair.h"
#include "ClientSignatures.h"

static_assert(sizeof(void*) == 4, "Build for x86 only");
using SelectFn = int(__thiscall*)(void*);
using RenderFn = void(__fastcall*)(void*, int);
static SelectFn originalItem = nullptr;
static SelectFn originalVisible = nullptr;
static RenderFn originalRender = nullptr;
static HMODULE moduleHandle;
#ifdef ENCHANT_DIAGNOSTIC
static volatile LONG traceSequence=0;
static __declspec(thread) unsigned renderDepth=0;
static bool DiagnosticHooksRequested() {
    char path[MAX_PATH];
    DWORD length=GetModuleFileNameA(moduleHandle,path,MAX_PATH);
    if(!length || length>=MAX_PATH) return false;
    char* slash=strrchr(path,'\\');
    if(!slash || strcpy_s(slash+1,MAX_PATH-static_cast<size_t>(slash+1-path),"EnchantVisualsDiagnostic.ini")) return false;
    return GetPrivateProfileIntA("Diagnostic","EnableHooks",0,path)==1;
}
#endif

static void Log(const char* message) {
    char path[MAX_PATH];
    DWORD length = GetModuleFileNameA(moduleHandle, path, MAX_PATH);
    if (!length || length >= MAX_PATH) return;
    char* slash = strrchr(path, '\\');
    if (!slash) return;
    size_t remaining = MAX_PATH - static_cast<size_t>(slash + 1 - path);
#ifdef ENCHANT_DIAGNOSTIC
    if (strcpy_s(slash + 1, remaining, "EnchantVisualsDiagnostic.log")) return;
#else
    if (strcpy_s(slash + 1, remaining, "EnchantVisuals.log")) return;
#endif
    FILE* file = nullptr;
    if (!fopen_s(&file, path, "a") && file) {
        fprintf(file, "%s\n", message);
        fclose(file);
    }
}

static void Trace(const char* stage, const void* object, int value) {
#ifdef ENCHANT_DIAGNOSTIC
    LONG sequence=InterlockedIncrement(&traceSequence);
    if(sequence>20000) return;
    char line[256];
    sprintf_s(line,"pid=%lu tid=%lu tick=%lu seq=%ld depth=%u %s object=%p value=%08X",GetCurrentProcessId(),GetCurrentThreadId(),GetTickCount(),sequence,renderDepth,stage,object,static_cast<unsigned>(value));
    Log(line);
#else
    (void)stage; (void)object; (void)value;
#endif
}

static uint32_t Visual(uint32_t enchantment) {
    const int maximum = *reinterpret_cast<const int*>(0xC0D7DC);
    auto entries = *reinterpret_cast<const uint8_t* const* const*>(0xC0D7D8);
    if (!enchantment || maximum < 0 || enchantment > static_cast<uint32_t>(maximum) || !entries)
        return 0;
    const uint8_t* row = entries[enchantment];
    return row ? *reinterpret_cast<const uint32_t*>(row + 0x58) : 0;
}

static bool ValidVisual(uint32_t visual) {
    int maximum = *reinterpret_cast<const int*>(0xC0DB74);
    auto entries = *reinterpret_cast<const void* const* const*>(0xC0DB70);
    return visual && maximum >= 0 && visual <= static_cast<uint32_t>(maximum) && entries && entries[visual];
}

static int Pair(int selected, uint32_t permanentID, uint32_t temporaryID) {
    uint32_t permanent = Visual(permanentID), temporary = Visual(temporaryID);
    if (!ValidVisual(permanent) || !ValidVisual(temporary)) return selected;
    return EnchantVisuals::Combine(selected, permanent, temporary);
}

static int __fastcall SelectItem(void* item, void*) {
    Trace("item-original-enter",item,0);
    int selected = originalItem(item);
    Trace("item-original-exit",item,selected);
    if (selected <= 0) return selected; // Includes the built-in visual sentinel.
    auto data = *reinterpret_cast<const uint8_t* const*>(static_cast<uint8_t*>(item) + 0x114);
    int result=Pair(selected, *reinterpret_cast<const uint32_t*>(data + 0x40),
                         *reinterpret_cast<const uint32_t*>(data + 0x4C));
    Trace("item-result",item,result);
    return result;
}

static int __fastcall SelectVisible(void* record, void*) {
    Trace("visible-original-enter",record,0);
    int selected = originalVisible(record);
    Trace("visible-original-exit",record,selected);
    if (selected <= 0) return selected;
    auto fields = static_cast<const uint32_t*>(record);
    int result=Pair(selected, fields[3], fields[4]);
    Trace("visible-result",record,result);
    return result;
}

// The normal renderer clears all child effects first (call at 0x47970A).
// Recreate its stack frame and enter immediately after that call for the
// second effect. Everything after this entry uses the client's own code.
// Signature checks below cover this entire routine and attachment/cleanup.
__declspec(naked) static void __fastcall AppendVisual(void*, int) {
    __asm {
        push ebp
        mov ebp, esp
        push ecx
        push ebx
        push esi
        mov esi, edx
        mov ebx, ecx
        mov eax, 0047970Fh
        jmp eax
    }
}

static void __fastcall Render(void* model, int visual) {
#ifdef ENCHANT_DIAGNOSTIC
    ++renderDepth;
#endif
    Trace("render-enter",model,visual);
    uint32_t permanent = 0, temporary = 0;
    if (!EnchantVisuals::Decode(visual, permanent, temporary)) {
        originalRender(model, visual);
        Trace("render-normal-exit",model,visual);
#ifdef ENCHANT_DIAGNOSTIC
        --renderDepth;
#endif
        return;
    }
    Trace("permanent-enter",model,static_cast<int>(permanent));
    originalRender(model, static_cast<int>(permanent));
    Trace("permanent-exit",model,static_cast<int>(permanent));
    Trace("append-enter",model,static_cast<int>(temporary));
    AppendVisual(model, static_cast<int>(temporary));
    Trace("append-exit",model,static_cast<int>(temporary));
#ifdef ENCHANT_DIAGNOSTIC
    --renderDepth;
#endif
}

static bool Compatible() {
    if (reinterpret_cast<uintptr_t>(GetModuleHandleW(nullptr)) != 0x400000) return false;
    for (const auto& signature : clientSignatures) {
        MEMORY_BASIC_INFORMATION region{};
        if (!VirtualQuery(reinterpret_cast<void*>(signature.address), &region, sizeof(region)) ||
            region.State != MEM_COMMIT || (region.Protect & (PAGE_NOACCESS | PAGE_GUARD)) ||
            signature.address + signature.length > reinterpret_cast<uintptr_t>(region.BaseAddress) + region.RegionSize)
            return false;
        auto bytes = reinterpret_cast<const uint8_t*>(signature.address);
        uint64_t hash = 14695981039346656037ull;
        for (size_t i = 0; i < signature.length; ++i) {
            hash ^= bytes[i];
            hash *= 1099511628211ull;
        }
        if (hash != signature.hash) return false;
    }
    return true;
}

static bool Install() {
    if (!Compatible()) {
        Log("DISABLED: unsupported or already modified renderer. No hooks installed.");
        return false;
    }
    if (MH_Initialize() != MH_OK) {
        Log("DISABLED: MinHook initialization failed.");
        return false;
    }
    const uintptr_t targets[] = {0x5D9B70, 0x62EC70, 0x479700};
    void* detours[] = {reinterpret_cast<void*>(&SelectItem), reinterpret_cast<void*>(&SelectVisible), reinterpret_cast<void*>(&Render)};
    void** originals[] = {reinterpret_cast<void**>(&originalItem), reinterpret_cast<void**>(&originalVisible), reinterpret_cast<void**>(&originalRender)};
    for (size_t i = 0; i < 3; ++i) {
        if (MH_CreateHook(reinterpret_cast<void*>(targets[i]), detours[i], originals[i]) != MH_OK) {
            MH_Uninitialize();
            Log("DISABLED: hook creation failed. No hooks enabled.");
            return false;
        }
    }
    if (MH_EnableHook(MH_ALL_HOOKS) != MH_OK) {
        MH_DisableHook(MH_ALL_HOOKS);
        MH_Uninitialize();
        Log("DISABLED: hook activation failed.");
        return false;
    }
    Log("ENABLED: experimental permanent glow + active shaman imbue rendering.");
    return true;
}

BOOL WINAPI DllMain(HINSTANCE instance, DWORD reason, LPVOID) {
    if (reason == DLL_PROCESS_ATTACH) {
        moduleHandle = instance;
#ifdef ENCHANT_DIAGNOSTIC
        Trace("diagnostic-process-start",instance,0);
        if(!DiagnosticHooksRequested()) {
            Log("CONTROL ONLY: no client hooks installed; visual behavior unchanged.");
            return TRUE;
        }
#endif
        DisableThreadLibraryCalls(instance);
        Install();
    }
    // Loaded for the process lifetime by VanillaFixes. Do not unload live.
    return TRUE;
}
