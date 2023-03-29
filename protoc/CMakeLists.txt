# get protobuf
find_package(Protobuf REQUIRED)
include_directories(${PROTOBUF_INCLUDE_DIRS})

find_package(Threads REQUIRED)


# 所有的proto文件
file(GLOB_RECURSE GPROTOC_PROTO_FILES "*.proto")

# 捞出shared的proto文件名
file(GLOB_RECURSE PROTO_SHARED_FILE_NAMES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "*.proto")

# 捞出protos下的proto文件名
# file(GLOB_RECURSE PROTO_FILE_NAMES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/protos "protos/*.proto")

# 把shared也追加进去
list(APPEND PROTO_FILE_NAMES ${PROTO_SHARED_FILE_NAMES})

foreach(proto_file_name ${PROTO_FILE_NAMES})
	# 利用正则替换得到源文件名，加入到GPROTOC_GENERATED_FILES中
	STRING(REGEX REPLACE "^(.+).proto$" "${CMAKE_CURRENT_SOURCE_DIR}/gprotoc/\\1.pb.cc" PROTO_SOURCE ${proto_file_name})
	list(APPEND GPROTOC_GENERATED_FILES ${PROTO_SOURCE})
	# 利用正则替换得到相对于当前目录的路径，加入到GPROTOC_PROTO_FILES_STRINGS中
	STRING(REGEX REPLACE "^(.+)$" "protos.tmp/\\1" PROTO_STRING ${proto_file_name})
	set(GPROTOC_PROTO_FILES_STRINGS "${GPROTOC_PROTO_FILES_STRINGS} ${PROTO_STRING}")
endforeach()

message(STATUS "===> PROTO_FILE_NAMES:${PROTO_FILE_NAMES}")
message(STATUS "===> GPROTOC_PROTO_FILES:${GPROTOC_PROTO_FILES}")
message(STATUS "===> GPROTOC_GENERATED_FILES:${GPROTOC_GENERATED_FILES}")
message(STATUS "===> GPROTOC_PROTO_FILES_STRINGS:${GPROTOC_PROTO_FILES_STRINGS}")

add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/protogen.stamp
		COMMAND mkdir -p gprotoc && mkdir -p gprotoc.tmp && mkdir -p protos.tmp
		# COMMAND cd protos.tmp && ln -sf ../shared_protobuf/* . && ln -sf ../protos/* .
        COMMAND cd protos.tmp && ln -sf ../* .
		# 这里使用cpp扩展插件来生成代码，比源生的多了些项目自定义的东西
		COMMAND echo "${GPROTOC_PROTO_FILES_STRINGS}" | xargs ls | xargs -P 0 -iPATH protoc PATH -I ./protos.tmp  --cpp_out=./gprotoc.tmp
		COMMAND rsync -cqr gprotoc.tmp/ gprotoc/
		COMMAND rm -rf gprotoc.tmp protos.tmp
		COMMAND cmake -E touch ${CMAKE_CURRENT_BINARY_DIR}/protogen.stamp
		COMMENT "Generating protobuf source files"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		DEPENDS 
			${PB_PROTOC_EXE}
			${GPROTOC_PROTO_FILES}
)


add_custom_target(gprotoc-gen
	DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/protogen.stamp
)

### PB生成的文件打包成一个库
add_library(gprotoc ${GPROTOC_GENERATED_FILES})
add_dependencies(gprotoc gprotoc-gen)
target_link_libraries(gprotoc ${PROTOBUF_LIBRARY} ${CMAKE_THREAD_LIBS_INIT})
target_include_directories(gprotoc
	PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}"
	PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/gprotoc/"
	PUBLIC "${PROTOBUF_INCLUDE_DIRS}"
)
set_source_files_properties(${GPROTOC_GENERATED_FILES}
	PROPERTIES GENERATED TRUE)


include(AddHeaderTarget)
add_header_target(gprotoc_header gprotoc)
