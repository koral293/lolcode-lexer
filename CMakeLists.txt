cmake_minimum_required(VERSION 3.28)
project(LOLCODE C)

set(CMAKE_C_STANDARD 11)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

BISON_TARGET(Parser parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.tab.c COMPILE_FLAGS "-d")
FLEX_TARGET(Lexer lexer.l ${CMAKE_CURRENT_BINARY_DIR}/lex.yy.c)
ADD_FLEX_BISON_DEPENDENCY(Lexer Parser)

add_executable(LOLCODE ${BISON_Parser_OUTPUTS} ${FLEX_Lexer_OUTPUTS})

target_compile_options(LOLCODE PRIVATE -Wall -Wextra)
target_link_libraries(LOLCODE m)
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_BINARY_DIR}/bin)
