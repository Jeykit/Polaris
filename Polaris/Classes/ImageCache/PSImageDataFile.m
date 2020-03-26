//
//  PSImageDataFile.m
//  Expecta
//
//  Created by Jekity on 2019/8/26.
//

#import "PSImageDataFile.h"
#import <sys/mman.h>
#import "PSImageCacheUtils.h"

@implementation PSImageDataFile
{
    NSString* _filePath;
    int _fileDescriptor;
    size_t _maxLength; // default is 1000Mb.
    
    NSRecursiveLock* _lock;
}
- (instancetype)initWithPath:(NSString*)path
{
    if (self = [super init]) {
        _filePath = [path copy];
        _maxLength = 1024 * 1024 * 1024;
        _lock = [[NSRecursiveLock alloc] init];
        _fileDescriptor = -1;
    }
    return self;
}
- (void)dealloc
{
    // should close the file if it's not be used again.
    [self close];
}
- (NSString *)filePath{
    
    [_lock lock];
    NSString *path = [_filePath copy];
    [_lock unlock];
    
    return path;
}
- (BOOL)open
{
    
    [_lock lock];
    _fileDescriptor = open([_filePath fileSystemRepresentation], O_RDWR | O_CREAT, 0666);
    if (_fileDescriptor < 0) {
        NSLog(@"can't file at %@", _filePath);
        [_lock unlock];
        return NO;
    }
    [_lock unlock];
    _fileLength = lseek(_fileDescriptor, 0, SEEK_END);
    if (_fileLength == 0) {
        [self increaseFileLength:(size_t)1];
    } else {
        [self mmap];
    }
    
    return YES;
}

- (void)close
{
    if (_fileDescriptor < 0) {
        return;
    }
    
    [_lock lock];
    
    close(_fileDescriptor);
    _fileDescriptor = -1;
    [_lock unlock];
    
    // 取消内存映射
    [self munmap];
    
}

- (void)munmap
{
    if (_address == NULL) {
        return;
    }
    
    [_lock lock];
    munmap(_address, (size_t)_fileLength);
    _address = NULL;
    [_lock unlock];
}

- (void)mmap
{
    _address = mmap(NULL, (size_t)_fileLength, (PROT_READ | PROT_WRITE), (MAP_FILE | MAP_SHARED), _fileDescriptor, 0);
}

- (BOOL)prepareAppendDataWithOffset:(size_t)offset length:(size_t)length
{
    NSAssert(_fileDescriptor > -1, @"open this file first.");
    [_lock lock];
    // can't exceed maxLength
    if (offset + length > _maxLength) {
        [_lock unlock];
        return NO;
    }
    // Check the file length, if it is not big enough, then increase the file length with step.
    if (offset + length > _fileLength) {
        if (![self increaseFileLength:length]) {
            [_lock unlock];
            return NO;
        }
    }
    [_lock unlock];
    return YES;
}

- (BOOL)appendDataWithOffset:(size_t)offset length:(size_t)length
{
    NSAssert(_fileDescriptor > -1, @"open this file first.");
    
    [_lock lock];
    /**aligned page .avoid crash 同步时进行page对齐，防止拷贝出错*/
    int pageSize = [PSImageCacheUtils pageSize];
    void *address = _address;
    size_t pageIndex = (size_t)address / pageSize;
    void *pageAlignedAddress = (void *)(pageIndex * pageSize);
    size_t bytesBeforeData = address - pageAlignedAddress;
    size_t bytesToFlush = (bytesBeforeData + length);
    //end
    int result = msync(pageAlignedAddress, bytesToFlush, MS_SYNC);
    if (result < 0) {
        NSLog(@"append data failed");
        [_lock unlock];
        return NO;
    }
    
    [_lock unlock];
    
    return YES;
}
- (BOOL)increaseFileLength:(size_t)length
{
    // cancel map first
    [self munmap];
    [_lock lock];
    int newFileDescriptor = _fileDescriptor;
    size_t newFileLength = _fileLength + length;
    // change file length
    int result = ftruncate(newFileDescriptor, newFileLength);
    if (result < 0) {
        NSLog(@"can't truncate data file");
        [_lock unlock];
        return NO;
    }
    // remap
    _fileLength = lseek(_fileDescriptor, 0, SEEK_END);
    [self mmap];
    [_lock unlock];
    
    return YES;
}

@end
