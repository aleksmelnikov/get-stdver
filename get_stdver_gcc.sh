#!/bin/bash

# MIT License
#
# Copyright (c) 2026 Aleksey Melnikov <dailyadm@yandex.ru>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#####################################################################################
# Назначение скрипта:
# Данный скрипт предназначен для автоматизации процесса поиска версий по умолчанию 
# C и С++ в исходных файлах проекта GCC (GNU Compiler Collection) по релизным тегам.
#
# Использование скрипта:
# cd /tmp
# git clone git://gcc.gnu.org/git/gcc.git
# git clone https://git@git.sourcecraft.dev/dbvmcom/get-stdver.git
# /tmp/get_stdver/get_stdver_gcc.sh /tmp/gcc
#
# Дополнительная информация:
# cpp_create_reader - это ключевая внутренняя функция, которая инициализирует препроцессор.
# Один из ее аргументов - это начальный идентификатор стандарта языка.
# В последующих версиях GCC дополнительно к этой установке идентификатор стандарта языка 
# стали задавать через 'enum cxx_dialect cxx_dialect = cxx98;'
# В последующих версиях GCC сделали 'enum cxx_dialect cxx_dialect = cxx_unset;' и стали
# задавать стандарт языка через непосредственный вызов функций вида 'set_std_*'.
#
# Пример данных на выходе скрипта:
# Processing tag: releases/gcc-15.2.0
#   gcc/c-family/c-opts.cc
#     246:  parse_in = cpp_create_reader (c_dialect_cxx () ? CLK_GNUCXX : CLK_GNUC89,
#     247-				ident_hash, line_table, ident_hash_extra);
#     248-  cb = cpp_get_callbacks (parse_in);
#  gcc/c-family/c-opts.cc
#     264:      /* The default for C is gnu23.  */
#     265-      set_std_c23 (false /* ISO */);
#     266-
#  gcc/c-family/c-opts.cc
#     277:  /* Set C++ standard to C++17 if not specified on the command line.  */
#     278-  if (c_dialect_cxx ())
#     279-    set_std_cxx17 (/*ISO*/false);
# Здесь:
# строка  1: Анализируемый текущий тег (15.2.0)
# строка  3: Задаются начальные идентификаторы стандартов: для С - CLK_GNUC89, для С++ - CLK_GNUCXX.
# строка  8: Установка конечного стандарта для С   - gnu23.
# строка 13: Установка конечного стандарта для С++ - c++17.
#####################################################################################

#####################################################################################
# Purpose of the script:
# This script automates the process of finding default versions of C and C++
# standards in the source files of the GCC project (GNU Compiler Collection),
# specifically looking through release tags.
#
# Usage example:
# cd /tmp
# git clone git://gcc.gnu.org/git/gcc.git
# git clone https://git@git.sourcecraft.dev/dbvmcom/get-stdver.git
# /tmp/get_stdver/get_stdver_gcc.sh /tmp/gcc
#
# Additional information:
# cpp_create_reader is a key internal function that initializes the preprocessor.
# One of its arguments is the initial language standard identifier.
# In subsequent versions of GCC, in addition to this setting, 
# the language standard identifier was set through 'enum cxx_dialect cxx_dialect = cxx98;'.
# In later versions of GCC, they made 'enum cxx_dialect cxx_dialect = cxx_unset;'
# and started specifying the language standard via direct calls to functions like 'set_std_*'.
#
# Example output data:
# Processing tag: releases/gcc-15.2.0
#   gcc/c-family/c-opts.cc
#     246:  parse_in = cpp_create_reader (c_dialect_cxx () ? CLK_GNUCXX : CLK_GNUC89,
#     247-				ident_hash, line_table, ident_hash_extra);
#     248-  cb = cpp_get_callbacks (parse_in);
#  gcc/c-family/c-opts.cc
#     264:      /* The default for C is gnu23.  */
#     265-      set_std_c23 (false /* ISO */);
#     266-
#  gcc/c-family/c-opts.cc
#     277:  /* Set C++ standard to C++17 if not specified on the command line.  */
#     278-  if (c_dialect_cxx ())
#     279-    set_std_cxx17 (/*ISO*/false);
# Here:
# line  1: The current analyzed tag (15.2.0)
# line  3: Initial standard identifiers are defined: for С - CLK_GNUC89, for С++ - CLK_GNUCXX.
# line  8: Final standard for C is set as gnu23.
# line 13: Final standard for C++ is set as c++17.
#####################################################################################


# Local GCC repository directory
REPO_DIR="$1"

# Go to the specified directory
cd "$REPO_DIR" || exit 1

# Array of files we want to check
FILES_TO_CHECK=(
    "gcc/c-lang.c"
    "gcc/cp/lex.c"
    "gcc/c-opts.c"
    "gcc/c-common.c"
    "gcc/c-family/c-opts.c"
    "gcc/c-family/c-opts.cc"
    "gcc/c-family/c-common.c"
)

# Array of strings we're searching within these files
SEARCH_STRINGS=(
    "cpp_create_reader"
    "enum cxx_dialect cxx_dialect"
    "/* The default for C is"
    "/* Set C++ standard to"
)

# Step 1: Collect both types of tags ('releases/gcc-*' and 'basepoints/gcc-*') and sort them
tags_sorted_by_refname=$(git for-each-ref --sort=v:refname \
              --format="%(refname:lstrip=2)" refs/tags/releases/gcc-*.*.* refs/tags/basepoints/gcc-* \
              | awk -F '/' '{ print $NF "\t" $0 }' | sort -V | cut -f2- )

# Step 2: Process each tag in order of its refname
for tag in $tags_sorted_by_refname; do
    echo "Processing tag: ${tag}"

    # Do search by searhing strings
    for FILE_NAME in "${FILES_TO_CHECK[@]}"; do
        # Check if the file exists at this tag
        if ! git show "${tag}:${FILE_NAME}" > /dev/null 2>&1; then
            continue
        fi

        # Retrieve file contents at this tag
        file_contents=$(git show "${tag}:${FILE_NAME}")

	# Save retrieved file contents to a file
	#mkdir -p /tmp/tmp
        #sanitized_tag="${tag//\//_}"
	#echo "$file_contents" > /tmp/tmp/${sanitized_tag}"-"$(basename ${FILE_NAME})

        # Search each string from the SEARCH_STRINGS array
        for search_string in "${SEARCH_STRINGS[@]}"; do
            # Find lines containing the substring using grep
            matching_lines=$(echo "$file_contents" | grep -n -A2 "$search_string")
            pretty_matching_lines=$(echo "$matching_lines" | sed 's/^/    /')

            if [ -n "$matching_lines" ]; then
	        pretty_FILE_NAME=$(echo "${FILE_NAME}" | sed 's/^/  /')
                echo "${pretty_FILE_NAME}"
		echo "${pretty_matching_lines}"
            fi
        done
    done
done
