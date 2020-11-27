LIB_NAME := CuGLView

ifndef OPTLEVEL
OPTLEVEL := 0
endif

ifndef ZLIB_ENABLE
ZLIB_ENABLE := 0
endif


CURRENT_BASEIDIR   = $(shell pwd)
CURRENT_SRC_DIR   := ${CURRENT_BASEIDIR}/src
CURRENT_LIB_DIR   := ${CURRENT_BASEIDIR}/lib
CURRENT_OBJ_DIR   := ${CURRENT_BASEIDIR}/obj
CURRENT_HDR_DIR   := ${CURRENT_BASEIDIR}/include
CURRENT_DOC_DIR   := ${CURRENT_BASEIDIR}/docs
CURRENT_TST_DIR   := ${CURRENT_BASEIDIR}/testing
CURRENT_HDRHX_DIR := ${CURRENT_BASEIDIR}/includex


IFLAGS_DEPENDENCIES :=

LFLAGS_DEPENDENCIES :=
LFLAGS_DEPENDENCIES += -lglut -lGL -lGLU -lGLEW

ifeq (${ZLIB_ENABLE}, 1)
LFLAGS_DEPENDENCIES += -lz
endif

CURRENT_IFLAGS := -I${CURRENT_HDR_DIR} -I${CURRENT_HDRHX_DIR}

SRC_FILES_HYBRID_H      := $(shell find ${CURRENT_SRC_DIR} -name *.cppx)
SRC_FILES_HYBRID_D      := $(shell find ${CURRENT_SRC_DIR} -name *.cppx)
SRC_FILES_HOST          := $(shell find ${CURRENT_SRC_DIR} -name *.cpp)
SRC_FILES_CUDA          := $(shell find ${CURRENT_SRC_DIR} -name *.cu)

HEADER_FILES    := $(shell find ${CURRENT_SRC_DIR} -name *.h)
HEADER_FILES_HX := $(shell find ${CURRENT_SRC_DIR} -name *.hx)

ifndef TESTS
TESTS := $(wildcard ${CURRENT_TST_DIR}/*)
else
TESTS := $(addprefix ${CURRENT_TST_DIR}/, ${TESTS})
endif


TARGET := ${CURRENT_LIB_DIR}/lib${LIB_NAME}.a

PY_EXE := $(shell which python3)
CC_HOST := $(shell which g++)
CC_DEVICE :=  $(shell which nvcc) -ccbin=${CC_HOST}

CU_O_TARGET_NAME := ${CURRENT_OBJ_DIR}/CU_dlink.o
LINK_STEP := link_step
CU_O_TARGET := ${CU_O_TARGET_NAME}
ICUDA := -I/usr/local/cuda/include
LCUDA := -L/usr/local/cuda/lib64 -lcudadevrt -lcudart

COMPILE_TIME_OPT :=
COMPILE_TIME_OPT +=



DEVICE_FLAGS := -O${OPTLEVEL} -x cu -rdc=true -Xcompiler -fPIC ${COMPILE_TIME_OPT} -dc
DEVICE_DLINK_FLAGS := -Xcompiler -fPIC -rdc=true -dlink
HOST_FLAGS := -O${OPTLEVEL} -x c++ -Wno-unknown-pragmas -fPIC -fpermissive -std=c++11 -Werror -c ${LCUDA}

LZLIB :=
ifeq (${ALLOW_DEBUG_EXT}, 1)
LZLIB := -lz
endif

ifeq (0, ${CUDA_ENABLE})
SRC_FILES_HYBRID_D :=
endif


TARGETNAME_HYBRID_H := $(addprefix ${CURRENT_OBJ_DIR}/,$(addsuffix .o,$(notdir ${SRC_FILES_HYBRID_H})))
TARGETNAME_HYBRID_D := $(addprefix ${CURRENT_OBJ_DIR}/,$(addsuffix .o,$(notdir ${SRC_FILES_HYBRID_D})))
TARGETNAME_HOST     := $(addprefix ${CURRENT_OBJ_DIR}/,$(addsuffix .o,$(notdir ${SRC_FILES_HOST})))
TARGETNAME_CUDA     := $(addprefix ${CURRENT_OBJ_DIR}/,$(addsuffix .o,$(notdir ${SRC_FILES_CUDA})))

SRC_FILES_HOST_DIR := $(dir ${SRC_FILES_HOST})
MP:=%
	
OBJ_FILES_CUDA := ${TARGETNAME_CUDA} ${TARGETNAME_HYBRID_D}

ifeq (,${TARGETNAME_HYBRID_D})
ifeq (,${TARGETNAME_CUDA})
LINK_STEP :=
endif
endif
CURRENT_IFLAGS += ${ICUDA}
export CURRENT_ICONFIG=-I${CURRENT_HDR_DIR} ${ICUDA} ${IFLAGS_DEPENDENCIES}
export CURRENT_LCONFIG= ${LCUDA} -L${CURRENT_LIB_DIR} -l${LIB_NAME} ${LFLAGS_DEPENDENCIES}
export CC_HOST
export CURRENT_BASEIDIR
export DIM

.PHONY: final docs

final: setup ${TARGETNAME_CUDA} ${TARGETNAME_HYBRID_D} ${LINK_STEP} ${TARGETNAME_HYBRID_H} ${TARGETNAME_HOST}
	${CC_HOST} -fPIC -shared ${CURRENT_OBJ_DIR}/*.o ${CURRENT_IFLAGS} ${IFLAGS_DEPENDENCIES} ${COMPILE_TIME_OPT} ${LZLIB} ${LCUDA} ${LFLAGS_DEPENDENCIES} -o ${TARGET}

example: final
	${MAKE} -C ${CURRENT_BASEIDIR}/example -f makefile run

.SECONDEXPANSION:
${TARGETNAME_HYBRID_D}: ${CURRENT_OBJ_DIR}/%.o : $$(filter $$(MP)/$$*,$$(SRC_FILES_HYBRID_D))
	${CC_DEVICE} ${DEVICE_FLAGS} ${COMPILE_TIME_OPT} ${CURRENT_IFLAGS} ${IFLAGS_DEPENDENCIES} $< -o $@

.SECONDEXPANSION:
${TARGETNAME_HYBRID_H}: ${CURRENT_OBJ_DIR}/%.o : $$(filter $$(MP)/$$*,$$(SRC_FILES_HYBRID_H))
	${CC_HOST} ${HOST_FLAGS} ${COMPILE_TIME_OPT} ${CURRENT_IFLAGS} ${IFLAGS_DEPENDENCIES} $< -o $@

.SECONDEXPANSION:
${TARGETNAME_HOST}: ${CURRENT_OBJ_DIR}/%.o : $$(filter $$(MP)/$$*,$$(SRC_FILES_HOST))
	${CC_HOST} ${HOST_FLAGS} ${COMPILE_TIME_OPT} ${CURRENT_IFLAGS} ${IFLAGS_DEPENDENCIES} $< -o $@

.SECONDEXPANSION:
${TARGETNAME_CUDA}: ${CURRENT_OBJ_DIR}/%.o : $$(filter $$(MP)/$$*,$$(SRC_FILES_CUDA))
	${CC_DEVICE} ${DEVICE_FLAGS} ${COMPILE_TIME_OPT} ${CURRENT_IFLAGS} ${IFLAGS_DEPENDENCIES} $< -o $@

${LINK_STEP}:
	${CC_DEVICE} ${DEVICE_DLINK_FLAGS} ${COMPILE_TIME_OPT} ${OBJ_FILES_HYBRID_DEVICE} ${OBJ_FILES_CUDA} -o ${CU_O_TARGET} -lcudadevrt

setup:
	-rm -r ${CURRENT_HDR_DIR}
	-rm -r ${CURRENT_HDRHX_DIR}
	mkdir -p ${CURRENT_LIB_DIR}
	mkdir -p ${CURRENT_OBJ_DIR}
	mkdir -p ${CURRENT_HDR_DIR}
	mkdir -p ${CURRENT_HDRHX_DIR}
	@for hdr in ${HEADER_FILES} ; do\
		echo "Linking $${hdr}:";\
		ln -s $${hdr} -t ${CURRENT_HDR_DIR};\
	done
	@for hdr in ${HEADER_FILES_HX} ; do\
		echo "Linking $${hdr}:";\
		ln -s $${hdr} -t ${CURRENT_HDRHX_DIR};\
	done

clean:
	-rm -r ${CURRENT_LIB_DIR}
	-rm -r ${CURRENT_OBJ_DIR}
	-rm -r ${CURRENT_HDR_DIR}
	-rm -r ${CURRENT_HDRHX_DIR}
	${MAKE} -C ${CURRENT_BASEIDIR}/example -f makefile clean

