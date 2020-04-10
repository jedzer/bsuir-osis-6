#include "pch.h"
#include <cstdlib>
#include <clocale>
#include <cstdio>
#include <windows.h>
#include <tchar.h>
#include <iostream>

using namespace std;

BOOL FindFileByClaster(TCHAR* volume, LONGLONG cluster) {

	HANDLE hDevice = CreateFile(volume,      // drive to open
		GENERIC_READ,                        // access to the drive
		FILE_SHARE_READ | FILE_SHARE_WRITE,  // share mode
		NULL,                                // default security attributes
		OPEN_EXISTING,                       // disposition
		FILE_FLAG_BACKUP_SEMANTICS,          // file attributes
		NULL);

	if (hDevice == INVALID_HANDLE_VALUE) {
		return FALSE;
	}

	//входные параметры
	LOOKUP_STREAM_FROM_CLUSTER_INPUT input = {0};
	input.NumberOfClusters = 1;
	input.Cluster[0].QuadPart = cluster;

	//буфер для результатов
	BYTE output[5000] = {};
	DWORD dwRes = 0;
	LOOKUP_STREAM_FROM_CLUSTER_OUTPUT result = {0};

	//пытаемся отправить IOCTL...
	BOOL bRes = DeviceIoControl((HANDLE)hDevice,    // handle to file, directory, or volume
		FSCTL_LOOKUP_STREAM_FROM_CLUSTER,			// dwIoControlCode
		(LPVOID)&input,								// input buffer
		(DWORD)sizeof(input),						// size of input buffer
		(LPVOID)output,								// output buffer
		(DWORD)5000,								// size of output bufferj
		(LPDWORD)&dwRes,							// number of bytes returned
		NULL);										// OVERLAPPED structure

	if (bRes == FALSE) {
		return FALSE;
	}

	//переносим результат из массива в структуру LOOKUP_STREAM_FROM_CLUSTER_OUTPUT
	memcpy(&result, output, sizeof(LOOKUP_STREAM_FROM_CLUSTER_OUTPUT));

	if (result.NumberOfMatches == 0) {
		cout << "File not found\n";
		return FALSE;
	}

	wprintf(L"File info\n");

	//переходим к адресу первой структуры LOOKUP_STREAM_FROM_CLUSTER_ENTRY
	BYTE* p = (BYTE*)output + result.Offset;
	LOOKUP_STREAM_FROM_CLUSTER_ENTRY* pentry = (LOOKUP_STREAM_FROM_CLUSTER_ENTRY*)p;

	wprintf(L"\nFile: %s\n", pentry->FileName);
	return TRUE;
}

int main() {
	LONGLONG inp = 0;
	printf_s("Enter cluster number:\n");
	scanf_s("%llu", &inp);

	FindFileByClaster((TCHAR*)L"\\\\.\\C:", inp);
	system("PAUSE");
}
