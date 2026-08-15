#include <jni.h>

// Stub JNI_OnLoad: return JNI_VERSION_1_6 to satisfy the VM
// without registering any native methods.
// This prevents the crash caused by the real libperfetto_framework_jni.so
// trying to RegisterNatives for PerfettoTrace classes that don't exist in OpenJDK.

JNIEXPORT jint JNICALL
JNI_OnLoad(JavaVM *vm, void *reserved) {
    (void)vm;
    (void)reserved;
    return JNI_VERSION_1_6;
}
