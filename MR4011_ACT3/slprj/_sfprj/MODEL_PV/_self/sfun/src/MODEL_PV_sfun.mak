# ------------------- Required for MSVC nmake ---------------------------------
# This file should be included at the top of a MAKEFILE as follows:


CPU = AMD64

MODEL     = MODEL_PV
TARGET      = sfun
MODULE_SRCS   = c13_MODEL_PV.c half_type.c
MODEL_SRC  = MODEL_PV_sfun.c
MODEL_REG = MODEL_PV_sfun_registry.c
MAKEFILE    = MODEL_PV_sfun.mak
MATLAB_ROOT  = C:\Program Files\MATLAB\R2024b
BUILDARGS   =

#--------------------------- Tool Specifications ------------------------------
#
#
MSVC_ROOT1 = $(MSDEVDIR:SharedIDE=vc)
MSVC_ROOT2 = $(MSVC_ROOT1:SHAREDIDE=vc)
MSVC_ROOT  = $(MSVC_ROOT2:sharedide=vc)

# Compiler tool locations, CC, LD, LIBCMD:
CC     = cl.exe
LD     = link.exe
LIBCMD = lib.exe
#------------------------------ Include/Lib Path ------------------------------

USER_INCLUDES   =  /I "C:\Users\ezeco\Documents\0 Maestria en Inteligencia Artificial Aplicada\MR4011 - Protocolos de Comunicacion Vehicular\Semana 6\ACT3\MR4011_ACT3" /I "C:\Users\ezeco\Documents\0 Maestria en Inteligencia Artificial Aplicada\MR4011 - Protocolos de Comunicacion Vehicular\Semana 6\ACT3\MR4011_ACT3\SIMULINK"
AUX_INCLUDES   = 
MLSLSF_INCLUDES = \
    /I "C:\Program Files\MATLAB\R2024b\extern\include" \
    /I "C:\Program Files\MATLAB\R2024b\simulink\include" \
    /I "C:\Program Files\MATLAB\R2024b\simulink\include\sf_runtime" \
    /I "C:\Program Files\MATLAB\R2024b\stateflow\c\mex\include" \
    /I "C:\Program Files\MATLAB\R2024b\rtw\c\src" \
    /I "C:\Users\ezeco\Documents\0 Maestria en Inteligencia Artificial Aplicada\MR4011 - Protocolos de Comunicacion Vehicular\Semana 6\ACT3\MR4011_ACT3\slprj\_sfprj\MODEL_PV\_self\sfun\src" 

COMPILER_INCLUDES = /I "$(MSVC_ROOT)\include"

THIRD_PARTY_INCLUDES   =  /I "C:\Program Files\MATLAB\R2024b\extern\include\shared_autonomous"
INCLUDE_PATH = $(USER_INCLUDES) $(AUX_INCLUDES) $(MLSLSF_INCLUDES)\
 $(THIRD_PARTY_INCLUDES)
LIB_PATH     = "$(MSVC_ROOT)\lib"

CFLAGS = /c /Zp8 /GR /W3 /EHs /D_CRT_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_DEPRECATE /D_SECURE_SCL=0 /DMX_COMPAT_64 /DMATLAB_MEXCMD_RELEASE=R2018a /DMATLAB_MEX_FILE /nologo /MD  
LDFLAGS = /nologo /dll /MANIFEST /OPT:NOREF /export:mexFunction /export:mexfilerequiredapiversion  
#----------------------------- Source Files -----------------------------------

REQ_SRCS  =  $(MODEL_SRC) $(MODEL_REG) $(MODULE_SRCS)

USER_OBJS =

AUX_ABS_OBJS =

THIRD_PARTY_OBJS     = \
     "c_mexapi_version.obj" \
     "autonomouscodegen_dubins.obj" \

REQ_OBJS = $(REQ_SRCS:.cpp=.obj)
REQ_OBJS2 = $(REQ_OBJS:.c=.obj)
OBJS = $(REQ_OBJS2) $(USER_OBJS) $(AUX_ABS_OBJS) $(THIRD_PARTY_OBJS)
OBJLIST_FILE = MODEL_PV_sfun.mol
SFCLIB = 
AUX_LNK_OBJS =     
USER_LIBS = 
#--------------------------------- Rules --------------------------------------

MEX_FILE_NAME_WO_EXT = $(MODEL)_$(TARGET)
MEX_FILE_NAME = $(MEX_FILE_NAME_WO_EXT).mexw64
MEX_FILE_CSF =
all : $(MEX_FILE_NAME) $(MEX_FILE_CSF)

$(MEX_FILE_NAME) : $(MAKEFILE) $(OBJS) $(SFCLIB) $(AUX_LNK_OBJS) $(USER_LIBS) $(THIRD_PARTY_LIBS)
 @echo ### Linking ...
 $(LD) $(LDFLAGS) /OUT:$(MEX_FILE_NAME) /map:"$(MEX_FILE_NAME_WO_EXT).map"\
  $(USER_LIBS) $(SFCLIB) $(AUX_LNK_OBJS)\
  $(DSP_LIBS) $(THIRD_PARTY_LIBS)\
  @$(OBJLIST_FILE)
	@echo ### Created $@

.c.obj :
	@echo ### Compiling "$<"
	$(CC) $(CFLAGS) $(INCLUDE_PATH) "$<"

.cpp.obj :
	@echo ### Compiling "$<"
	$(CC) $(CFLAGS) $(INCLUDE_PATH) "$<"


c_mexapi_version.obj :  "C:\Program Files\MATLAB\R2024b\extern\version\c_mexapi_version.c"
	@echo ### Compiling "C:\Program Files\MATLAB\R2024b\extern\version\c_mexapi_version.c"
	$(CC) $(CFLAGS) $(INCLUDE_PATH) "C:\Program Files\MATLAB\R2024b\extern\version\c_mexapi_version.c"
autonomouscodegen_dubins.obj :  "C:\Program Files\MATLAB\R2024b\toolbox\shared\autonomous\builtins\libsrc\autonomouscodegen\dubins\autonomouscodegen_dubins.cpp"
	@echo ### Compiling "C:\Program Files\MATLAB\R2024b\toolbox\shared\autonomous\builtins\libsrc\autonomouscodegen\dubins\autonomouscodegen_dubins.cpp"
	$(CC) $(CFLAGS) $(INCLUDE_PATH) "C:\Program Files\MATLAB\R2024b\toolbox\shared\autonomous\builtins\libsrc\autonomouscodegen\dubins\autonomouscodegen_dubins.cpp"
