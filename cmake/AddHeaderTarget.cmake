# 定义一个自动生成header接口库的方法
# 用法：
# add_header_target(<HEADER_TARGET> <ORIGIN_TARGET> [NO_LINK])
# 作用：
# 为一个已有的ORIGIN_TARGET，自动生成一个名为HEADER_TARGET的接口库
macro(add_header_target HEADER_TARGET ORIGIN_TARGET)
	# 定义额外参数表
	set(EXTRA_ARGS_LIST ${ARGN})
	# 取出原库add_dependencies中的参数，因为该属性不能被generator表达式获取，这里通过方法来获取
	get_target_property(ORIGIN_TARGET_DEPS ${ORIGIN_TARGET} MANUALLY_ADDED_DEPENDENCIES)
	add_library(${HEADER_TARGET} INTERFACE)
	add_dependencies(${HEADER_TARGET} ${ORIGIN_TARGET_DEPS})
	if("NO_LINK" IN_LIST EXTRA_ARGS_LIST)
		get_target_property(ORIGIN_TARGET_LINK_LIBS ${ORIGIN_TARGET} INTERFACE_LINK_LIBRARIES)
		add_dependencies(${HEADER_TARGET} ${ORIGIN_TARGET_LINK_LIBS})
	else()
		target_link_libraries(${HEADER_TARGET} INTERFACE $<TARGET_PROPERTY:${ORIGIN_TARGET},INTERFACE_LINK_LIBRARIES>)
	endif()
	target_include_directories(${HEADER_TARGET} INTERFACE $<TARGET_PROPERTY:${ORIGIN_TARGET},INTERFACE_INCLUDE_DIRECTORIES>)
	target_compile_definitions(${HEADER_TARGET} INTERFACE $<TARGET_PROPERTY:${ORIGIN_TARGET},INTERFACE_COMPILE_DEFINITIONS>)
	target_compile_options(${HEADER_TARGET} INTERFACE $<TARGET_PROPERTY:${ORIGIN_TARGET},INTERFACE_COMPILE_OPTIONS>)
endmacro()