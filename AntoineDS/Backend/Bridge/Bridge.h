//
//  Bridge.h
//  AntoineDS
//
//  Bridge header for Swift <-> ObjC interop
//

#ifndef Bridge_h
#define Bridge_h

@import Darwin;

#include "ActivityStreamAPI.h"
#include "ActivityEvents/ActivityEvents.h"
#include "../../DarkSword/DarkSwordExploit.h"

os_activity_stream_t *os_activity_stream_for_pid(pid_t pid,
                                                 os_activity_stream_flag_t flags,
                                                 os_activity_stream_block_t stream_block);

void os_activity_stream_resume(os_activity_stream_t stream);
void os_activity_stream_cancel(os_activity_stream_t stream);

void os_activity_stream_set_event_handler(os_activity_stream_t stream,
                                          os_activity_stream_event_block_t block);

NSString * _Nonnull antoineGetBuildDate(void);
NSString * _Nonnull antoineGetBuildTime(void);

#endif /* Bridge_h */
