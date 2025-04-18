﻿using System.Runtime.InteropServices;

namespace CsWhispers;

public static unsafe partial class Syscalls
{
    private const string ZwQueryVirtualMemoryHash = "0F4ECCBB2DFD9932319A2C18098B34E6";

    public static NTSTATUS NtQueryVirtualMemory(
        HANDLE processHandle,
        void* baseAddress,
        MEMORY_INFORMATION_CLASS memoryInformationClass,
        void* buffer,
        uint length,
        [Optional] uint* resultLength)
    {
        var stub = GetSyscallStub(ZwQueryVirtualMemoryHash);

        fixed (byte* temp = stub)
        {
            var ptr = (IntPtr)temp;
            var size = new IntPtr(stub.Length);

            Native.NtProtectVirtualMemory(
                new HANDLE((IntPtr)(-1)),
                ref ptr,
                ref size,
                0x00000020,
                out var oldProtect);

            var ntQueryVirtualMemory = Marshal.GetDelegateForFunctionPointer<ZwQueryVirtualMemory>(ptr);

            var status = ntQueryVirtualMemory(
                processHandle,
                baseAddress,
                memoryInformationClass,
                buffer,
                length,
                resultLength);

            Native.NtProtectVirtualMemory(
                new HANDLE((IntPtr)(-1)),
                ref ptr,
                ref size,
                oldProtect,
                out _);

            return status;
        }
    }

    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    private delegate NTSTATUS ZwQueryVirtualMemory(
        HANDLE processHandle,
        void* baseAddress,
        MEMORY_INFORMATION_CLASS memoryInformationClass,
        void* buffer,
        uint length,
        [Optional] uint* resultLength);
}