//
//  SignalM.h
//  Pods
//
//  Created by Jekity on 2019/8/2.
//

#ifndef SignalM_h
#define SignalM_h

#import "UIView+SignalM.h"

#undef  Click_SignalM
#define Click_SignalM(SignalName) \
- (void)SignalM_##SignalName:(id)object

#endif /* SignalM_h */
