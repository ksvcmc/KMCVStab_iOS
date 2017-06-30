//
//  KMCDefines.h
//  KMCVStab
//
//  Created by 张俊 on 30/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#ifndef KMCDefines_h
#define KMCDefines_h

typedef enum : NSUInteger {
    /**
     错误参数
     */
    AUTH_ERROR_WRONG_PARAMETER = 1001,
    /**
     token不匹配
     */
    AUTH_ERROR_TOKEN_NOT_MATCHED = 1002,
    /**
     token无效
     */
    AUTH_ERROR_TOKEN_NOT_VALID = 1003,
    /**
     未知错误
     */
    AUTH_ERROR_KMCS_ERROR_UNKONWN = 1004,
    /**
     第三方鉴权错误
     */
    AUTHORIZE_ERROR_FACTORY_ERROR = 1005,
    /**
     内部服务器错误
     */
    AUTHORIZE_SERVER_ERROR = 1006,
    /**
     token过期
     */
    AUTHORIZE_TOKEN_EXPIRE = 1007,
    /**
     服务器异常
     */
    AUTHORIZE_SERVICE_EXCEPTION = 1008
} AuthorizeError;

#endif /* KMCDefines_h */
