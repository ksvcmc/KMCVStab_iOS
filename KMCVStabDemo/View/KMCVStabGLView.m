//
//  KMCVStabGLView.m
//  KMCVStab
//
//  Created by 张俊 on 26/06/2017.
//  Copyright © 2017 ksyun. All rights reserved.
//

#import "KMCVStabGLView.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/CAEAGLLayer.h>

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

NSString *const kVStabVsh = SHADER_STRING
(
attribute vec4 position;
attribute mediump vec4 texCoord;
varying mediump vec2 coordinate;
void main()
{
    gl_Position = position;
    coordinate = texCoord.xy;
}
);


NSString *const kVStabFsh = SHADER_STRING(
varying highp vec2 coordinate;
uniform sampler2D original;
void main()
{
    gl_FragColor = texture2D(original, coordinate);
}
);


@interface KMCVStabGLView()
{
    CVOpenGLESTextureCacheRef textureCache;
    GLuint frameBufferHandle;
    GLuint colorBufferHandle;
    GLuint passThroughProgram;
    
    GLsizei width;
    GLsizei height;
}

enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    NUM_ATTRIBUTES
};

@property (nonatomic, assign) CGSize    videoSize;

@property (nonatomic, strong) EAGLContext *context;

@end

@implementation KMCVStabGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {

    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor blackColor];
    
    if (!_context){
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking  : @(NO),
                                         kEAGLDrawablePropertyColorFormat      : kEAGLColorFormatRGBA8};
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        if (!_context) {
            _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        }
        _videoSize = CGSizeMake(1080, 1920);
        [EAGLContext setCurrentContext:self.context];
    }
    
    if (frameBufferHandle == 0) {
        BOOL success = [self initializeBuffers];
        if (!success) {
            NSLog(@"Problem initializing OpenGL buffers.");
        }
    }
    

}


- (BOOL)initializeBuffers
{
    BOOL success = YES;
    
    self.contentScaleFactor = [[UIScreen mainScreen] scale];
    
    glDisable(GL_DEPTH_TEST);
    
    glGenFramebuffers(1, &frameBufferHandle);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferHandle);
    
    glGenRenderbuffers(1, &colorBufferHandle);
    glBindRenderbuffer(GL_RENDERBUFFER, colorBufferHandle);
    
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH,  &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorBufferHandle);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Faramebuffer generation failure:%d", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        //36054  GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
        success = NO;
        goto bail;
    }
    
    //  Create a new CVOpenGLESTexture cache
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &textureCache);
    if (err) {
        NSLog(@"Texture cache error:%d", err);
        success = NO;
        goto bail;
    }
    
    passThroughProgram = glCreateProgram();
    
    const GLchar *vshSource;
    const GLchar *fshSource;
    GLuint vshShader;
    GLuint fshShader;
    
    vshSource = (const GLchar *)[kVStabVsh UTF8String];
    fshSource = (const GLchar *)[kVStabFsh UTF8String];
    
    vshShader = glCreateShader(GL_VERTEX_SHADER);
    fshShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(vshShader, 1, &vshSource, NULL);
    glShaderSource(fshShader, 1, &fshSource, NULL);
    glCompileShader(vshShader);
    GLint logLength;
    glGetShaderiv(vshShader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(vshShader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
    glCompileShader(fshShader);
    glGetShaderiv(fshShader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(fshShader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
    
    glAttachShader(passThroughProgram, vshShader);
    glAttachShader(passThroughProgram, fshShader);
    
    glBindAttribLocation(passThroughProgram, ATTRIB_VERTEX,  "position");
    glBindAttribLocation(passThroughProgram, ATTRIB_TEXTUREPOSITON, "texCoord");
    
    glLinkProgram(passThroughProgram);
    
    if (!passThroughProgram) {
        NSLog(@"Error creating program");
        success = NO;
        goto bail;
    }
    
bail:
    if (!success) {
        [self reset];
    }
    return success;
}

- (void)reset
{
    [EAGLContext setCurrentContext:self.context];
    
    if (frameBufferHandle) {
        glDeleteFramebuffers(1, &frameBufferHandle);
        frameBufferHandle = 0;
    }
    if (colorBufferHandle) {
        glDeleteRenderbuffers(1, &colorBufferHandle);
        colorBufferHandle = 0;
    }
    if (passThroughProgram) {
        glDeleteProgram(passThroughProgram);
        passThroughProgram = 0;
    }
    if (textureCache) {
        CFRelease(textureCache);
        textureCache = 0;
    }
}

- (void)dealloc
{
    [self reset];
}

- (void)resetEAGLLayerFrame
{
    float w = self.bounds.size.width;
    float h = self.bounds.size.height;
    CGRect frame = self.bounds;
    CGSize videoSize = _videoSize;
    
    float scale = MAX(w / videoSize.width, h / videoSize.height);
    float fw = videoSize.width  * scale;
    float fh = videoSize.height * scale;
    frame = CGRectMake((w - fw) * 0.5f, (h - fh) * 0.5f, fw, fh);
    
    self.frame        = frame;
}

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    size_t frameWidth  = CVPixelBufferGetWidth(pixelBuffer);
    size_t frameHeight = CVPixelBufferGetHeight(pixelBuffer);
    
    if (frameWidth == 0.0f || frameHeight == 0.0f) {
        return;
    }
    
    if (_videoSize.width != frameHeight || _videoSize.height != frameWidth) {
        _videoSize = CGSizeMake(frameHeight, frameWidth);
        [self reset];
        [self resetEAGLLayerFrame];
        [self initializeBuffers];
    }
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        return;
    }
    
    [EAGLContext setCurrentContext:self.context];
    
    glBindFramebuffer(GL_FRAMEBUFFER, frameBufferHandle);
    glViewport(0, 0, width, height);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
   	
    // Create a CVOpenGLESTexture from the CVImageBuffer
    CVOpenGLESTextureRef texture = NULL;
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, pixelBuffer,
                                                                NULL, GL_TEXTURE_2D, GL_RGBA,
                                                                (GLsizei)frameWidth, (GLsizei)frameHeight, GL_BGRA,
                                                                GL_UNSIGNED_BYTE, 0, &texture);
    
    if (!texture || err) {
        NSLog(@"Mapping texture:%d", err);
        return;
    }
    
    glBindTexture(CVOpenGLESTextureGetTarget(texture), CVOpenGLESTextureGetName(texture));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    static const GLfloat renderVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat textureVertices[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    glUseProgram(passThroughProgram);
    
    GLint texLoc0;
    texLoc0 = glGetUniformLocation(passThroughProgram, "original");
    glUniform1i(texLoc0, 0);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, CVOpenGLESTextureGetName(texture));
    
    [self renderWithSquareVertices: renderVertices textureVertices:textureVertices];
    
    glBindTexture(CVOpenGLESTextureGetTarget(texture), 0 );
    CVOpenGLESTextureCacheFlush(textureCache, 0);
    CFRelease(texture);
    
    glFlush();
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)renderWithSquareVertices:(const GLfloat*)squareVertices
                 textureVertices:(const GLfloat*)textureVertices
{
    // Update attribute values.
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
    glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
