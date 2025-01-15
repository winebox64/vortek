
#import <Foundation/Foundation.h>
#import <Windows.h>

@interface Wine : NSObject

@property (nonatomic) uint32_t pc; // Program Counter
@property (nonatomic) uint32_t acc; // Accumulator
@property (nonatomic) uint32_t* memory; // Memory
@property (nonatomic) HWND hwnd; // Window handle

- (instancetype)init;
- (void)loadProgram:(NSData*)program;
- (void)execute;
- (void)reset;
- (void)createWindow;

@end

#import "Wine.h"

@implementation Wine

- (instancetype)init {
    self = [super init];
    if (self) {
        pc = 0;
        acc = 0;
        memory = malloc(1024 * sizeof(uint32_t));
        hwnd = NULL;
    }
    return self;
}

- (void)loadProgram:(NSData*)program {
    uint32_t* code = (uint32_t*)program.bytes;
    for (int i = 0; i < program.length / sizeof(uint32_t); i++) {
        memory[i] = code[i];
    }
}

- (void)execute {
    while (pc < 1024) {
        uint32_t instruction = memory[pc];
        pc++;

        switch (instruction) {
            case 0x01: // ADD
                acc += memory[pc];
                pc++;
                break;
            case 0x02: // SUB
                acc -= memory[pc];
                pc++;
                break;
            default:
                printf("Unknown instruction: %x\n", instruction);
                return;
        }
    }
}

- (void)reset {
    pc = 0;
    acc = 0;
}

- (void)createWindow {
    WNDCLASSEX wc = {0};
    wc.cbSize = sizeof(WNDCLASSEX);
    wc.lpfnWndProc = DefWindowProc;
    wc.hInstance = GetModuleHandle(NULL);
    wc.lpszClassName = "Wine";
    RegisterClassEx(&wc);

    hwnd = CreateWindowEx(
        0,
        "Winlator",
        "Wine Box64",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT,
        CW_USEDEFAULT,
        400,
        200,
        NULL,
        NULL,
        GetModuleHandle(NULL),
        NULL
    );

    ShowWindow(hwnd, SW_SHOW);
}

@end

#import <Foundation/Foundation.h>
#import "Wine.h"

int main(int argc, char* argv[]) {
    @autoreleasepool {
        Wine* vm = [[Wine alloc] init];

        // Example program
        uint32_t code[] = {0x01, 5, 0x02, 3};
        NSData* program = [NSData dataWithBytes:code length:sizeof(code)];

        [vm loadProgram:program];
        [vm createWindow];

        MSG msg;
        while (GetMessage(&msg, NULL, 0, 0)) {
            TranslateMessage(&msg);
            DispatchMessage(&msg);
        }

        [vm execute];
        printf("Result: %d\n", vm.acc);

        [vm reset];
    }
    return 0;
}

bash
gcc -o Wine.exe main.m Wine.m -lkernel32 -luser32 -lobjc
Run
Run the executable:
Wine.ex
